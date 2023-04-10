import time
import os
from dotenv import load_dotenv
from datetime import datetime
from playwright.async_api import async_playwright
from python_ghost_cursor.playwright_async import create_cursor
import asyncio

load_dotenv()

usernameStr = "arjun.prashanth2020@vitstudent.ac.in"
passwordStr = os.environ.get("PASSWORD")
if passwordStr is None:
    raise ValueError("Password not found in .env file")


async def main():

    async with async_playwright() as p:
        browser = await p.chromium.launch(
            args=[
                "--disable-gpu",
                # "--auto-open-devtools-for-tabs",
                "--deterministic-fetch",
                "--disable-features=IsolateOrigins",
                "--disable-site-isolation-trials",
                "--no-first-run",
            ],
            headless=False,
            # executablePath="/usr/bin/chromium",
        )
        page = await browser.new_page()
        cursor = create_cursor(page)

        # await page.emulate_viewport(
        #     {"name": "Desktop 1920x1080", "viewport": {"width": 1920, "height": 1080}}
        # )
        await page.set_viewport_size({"width": 1200, "height": 800})

        await page.goto("https://teams.microsoft.com/")

        # Email input field
        time.sleep(2)
        await page.wait_for_selector("#i0116")
        await page.type("#i0116", usernameStr)

        # Click the next button
        await cursor.click("#idSIButton9")
        await page.wait_for_selector("#i0118")
        await page.type("#i0118", passwordStr, delay=10)

        # Click the submit button
        await page.wait_for_selector("#idSIButton9")
        await cursor.click("#idSIButton9")
        await page.wait_for_selector("#idSIButton9")
        await cursor.click("#idSIButton9")
        # Click the Yes button

        try:
            # await page.wait_for_navigation(wait_until="networkidle", timeout=45000)
            await page.wait_for_selector(
                "#app-bar-66aeee93-507d-479a-a3ef-8f494af43945", timeout=25000
            )
            print("found Assignments sidebar button")
            # click it
            await cursor.click("#app-bar-66aeee93-507d-479a-a3ef-8f494af43945")
        except TimeoutError:
            print("Assignments sidebar button not found.")

        await asyncio.sleep(10)

        now = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
        directory_path = os.path.expanduser("~/.cache/assignments")

        # Create the directory if it doesn't exist
        if not os.path.exists(directory_path):
            os.makedirs(directory_path)

        file_path = os.path.join(directory_path, f"teams-assignments-{now}.png")
        await page.screenshot(path=file_path)
        await browser.close()

        print("Saved screenshot to", file_path)


asyncio.run(main())
