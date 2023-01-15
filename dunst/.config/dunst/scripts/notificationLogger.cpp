#include "gdkmm/screen.h"
#include "glibmm/refptr.h"
#include "gtkmm/iconinfo.h"
#include "gtkmm/overlay.h"
#include <algorithm>
#include <boost/algorithm/string.hpp>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <curl/curl.h>
#include <filesystem>
#include <fstream>
#include <gtk/gtk.h>
#include <gtkmm-3.0/gtkmm.h>
#include <gtkmm-3.0/gtkmm/icontheme.h>
#include <iostream>
#include <nlohmann/json.hpp>
#include <regex>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <wordexp.h>

enum Urgency
{
	LOW,
	NORMAL,
	CRITICAL
};
const std::unordered_map<std::string, Urgency> string_to_urgency = {
	{"LOW", Urgency::LOW},
	{"NORMAL", Urgency::NORMAL},
	{"CRITICAL", Urgency::CRITICAL}};
const std::unordered_map<Urgency, std::string> urgency_to_string = {
	{Urgency::LOW, "LOW"},
	{Urgency::NORMAL, "NORMAL"},
	{Urgency::CRITICAL, "CRITICAL"}};

size_t write_image_to_file(void *ptr, size_t size, size_t nmemb, void *userdata)
{
	FILE *stream = (FILE *)userdata;
	if (!stream)
	{
		printf("!!! No stream\n");
		return 0;
	}

	size_t written = fwrite((FILE *)ptr, size, nmemb, stream);
	return written;
}

class Notification
{
	using string = std::string;
	using json = nlohmann::json;
	string appname, summary, body, icon;
	string timestamp;
	Urgency urgency;
	std::shared_ptr<json> j;
	string get_spotify_image()
	{
		std::array<char, 128> buffer;
		string result;
		string random_name = std::string("/tmp/tempfileXXXXXX");
		auto fd = mkstemp((char *)random_name.c_str());
		close(fd);
		random_name += ".png";

		string cmd = "playerctl metadata mpris:artUrl | sed -e "
					 "'s/open.spotify.com/i.scdn.co/g'";
		std::shared_ptr<FILE> pipe(popen(cmd.c_str(), "r"), pclose);
		if (!pipe) throw std::runtime_error("popen() failed!");
		while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr)
		{
			result += buffer.data();
		}
		boost::trim_right(result);
		string artlink = result;

		FILE *fp;
		CURLcode res;
		auto curl = curl_easy_init();
		if (curl)
		{
			fp = fopen(random_name.c_str(), "wb");
			// printing with bunch of stars to see if there are any trailing
			// whitespaces
			// std::cout << artlink << "****";
			curl_easy_setopt(curl, CURLOPT_URL, artlink.c_str());
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_image_to_file);
			curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);

			res = curl_easy_perform(curl);
			if (res)
			{
				throw std::runtime_error("Unable to download image from link " +
										 artlink);
				return "";
			}
			long res_code = 0;
			curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &res_code);
			if (!((res_code == 200 || res_code == 201) &&
				  res != CURLE_ABORTED_BY_CALLBACK))
			{
				throw std::runtime_error("Response Code: " +
										 std::to_string(res_code));
				return "";
			}

			/* always cleanup */
			curl_easy_cleanup(curl);
			fclose(fp);
		}
		return random_name;
	}

  public:
	Notification(std::string appname, std::string summary, std::string body,
				 std::string icon, std::string urgency)
		: appname(std::move(appname)), summary(std::move(summary)),
		  body(std::move(body)), icon(std::move(icon)),
		  urgency(string_to_urgency.at(urgency))
	{
		auto now = std::chrono::system_clock::now();
		std::time_t now_c = std::chrono::system_clock::to_time_t(now);
		std::ostringstream time_stream;
		// Use put_time to format the time in ISO 8601 format
		time_stream << std::put_time(std::gmtime(&now_c), "%Y-%m-%dT%H:%M:%SZ");
		// Get the string from the stream
		std::string time_str = time_stream.str();
		j = std::make_shared<json>();
		(*j)["appname"] = this->appname;
		(*j)["summary"] = this->summary;
		(*j)["body"] = this->body;
		(*j)["icon"] =
			(this->appname == "Spotify"
				 ? get_spotify_image()
				 : (appname == "VLC media player" ? "vlc"
												  : get_gtk_icon_path()));
		(*j)["urgency"] = urgency_to_string.at(this->urgency);
		(*j)["timestamp"] = time_str;
	}
	std::string to_json() const;
	std::string get_gtk_icon_path(int size = 128) const;
	void dump_to_file(std::string fname) const;
};
std::string Notification::get_gtk_icon_path(int size) const
{

	if (size < 16)
	{
		auto xdg_config_home = std::getenv("XDG_CONFIG_HOME");
		if (xdg_config_home == nullptr)
		{
			auto config_dir = std::getenv("HOME");
			return config_dir + std::string("/eww/assets/bell.png");
		}
		auto temp = string(xdg_config_home);
		delete[] xdg_config_home;
		return temp + std::string("/eww/assets/bell.png");
	}
	auto info = gtk_icon_theme_lookup_icon(gtk_icon_theme_get_default(),
										   this->icon.c_str(), size,
										   (GtkIconLookupFlags)0);

	if (info)
	{
		const gchar *filename = gtk_icon_info_get_filename(info);
		gchar *res = g_strdup(filename);
		std::string result(res);
		g_free(res);
		g_object_unref(info);
		return result;
	}
	info = nullptr;
	return get_gtk_icon_path(size / 2);
}

std::string Notification::to_json() const { return j->dump(); }
void Notification::dump_to_file(string file_path) const
{
	wordexp_t p;
	if (wordexp(file_path.c_str(), &p, WRDE_NOCMD | WRDE_UNDEF) == 0)
	{
		std::string expanded_file_path = p.we_wordv[0];
		wordfree(&p);
		std::ofstream json_file;
		json_file.open(expanded_file_path, std::ios_base::app);
		if (!json_file.is_open())
		{
			throw std::ios_base::failure("Unable to open file " +
										 expanded_file_path);
		}
		json_file << to_json();
		json_file.close();
	}
	else
	{
		throw std::ios_base::failure(
			"Unable to evaluate environment variable in the path");
	}
}
int main(int argc, char *argv[])
{
	gtk_init(0, NULL);
	std::string appname = argv[1];
	std::string summary = argv[2];
	std::string body = argv[3];
	std::string icon = argv[4];
	std::string urgency = argv[5];
	const Notification *notif =
		new Notification(appname, summary, body, icon, urgency);
	std::string path = std::string(std::getenv("HOME")) + "/.cache/dunst";
	std::filesystem::create_directories(path);

	notif->dump_to_file(std::string(std::getenv("HOME")) +
						"/.cache/dunst/notifications.json");
	delete notif;
	return 0;
}
