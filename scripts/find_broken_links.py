import os
import re
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
import sys

def extract_urls_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    # Regular expression to capture valid URLs
    urls = re.findall(r'\bhttps?://[^\s\)]+(?<![\]\)])', content)

    # Filter out unwanted URLs
    filtered_urls = [
        url for url in urls 
        if not (
            url.startswith('http://192.168.') or
            url.startswith('https://192.168.') or
            url.startswith('http://10.') or
            url.startswith('https://10.') or
            url.startswith('http://127.0.0.1') or
            url.startswith('https://127.0.0.1') or
            url.startswith('https://web.archive.org') or
            url.startswith('http://@IP') or
            url.startswith('https://@IP') or
            url.startswith('http://apt.sw.be') or
            url.startswith('https://www.linuxquestions.org') or
            url.startswith('http://initiator-name') or
            url.endswith('.deb') or
            url.endswith('.rpm') or
            url.endswith('.jar') or
            url.endswith('.war') or
            '4.ifcfg.me' in url or
            'localhost' in url or
            'example.org' in url or
            'readthedocs.org' in url or
            'amazon.fr' in url or
            'www.cyberciti.biz' in url or
            'www.linuxquestions.org' in url or
            'sched.com' in url or
            '$' in url
        )
    ]
    return filtered_urls


def check_url(url):
    try:
        response = requests.head(url, allow_redirects=True, timeout=2)
        if response.status_code in [200, 301, 302]:
            return True
        else:
            return False
    except requests.RequestException:
        return False

def find_broken_links(directory):
    broken_links = {}
    total_files = sum(len(files) for _, _, files in os.walk(directory) if files)
    processed_files = 0

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                print(f"Processing file: {file_path} ({processed_files + 1}/{total_files})")
                urls = extract_urls_from_file(file_path)
                
                # Use ThreadPoolExecutor to check URLs in parallel
                with ThreadPoolExecutor(max_workers=10) as executor:
                    future_to_url = {executor.submit(check_url, url): url for url in urls}
                    for future in as_completed(future_to_url):
                        url = future_to_url[future]
                        try:
                            if not future.result():
                                if file_path not in broken_links:
                                    broken_links[file_path] = []
                                broken_links[file_path].append(url)
                        except Exception as e:
                            print(f"Error checking URL {url}: {e}")
                
                processed_files += 1
    return broken_links

if __name__ == '__main__':
    # Specify the top-level directory containing all yearly directories
    base_directory = 'content/post/'

    # Allow optional year argument
    year = None
    if len(sys.argv) > 1:
        year = sys.argv[1]
        directory = os.path.join(base_directory, year)
    else:
        directory = base_directory

    if not os.path.exists(directory):
        print(f"Error: Directory '{directory}' does not exist.")
        sys.exit(1)

    print(f"Scanning for broken links in: {directory}")
    broken_links = find_broken_links(directory)

    if broken_links:
        for file, urls in broken_links.items():
            print(f"\nBroken links found in {file}:")  # Add newline here for better readability
            for url in urls:
                print(f"  - {url}")
    else:
        print("No broken links found.")
