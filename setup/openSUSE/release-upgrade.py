import subprocess
import requests
import json

def get_current_version():
    """Retrieve the current openSUSE Leap version from /etc/os-release."""
    try:
        output = subprocess.check_output(
            "cat /etc/os-release | grep VERSION_ID | cut -d '\"' -f2",
            shell=True
        ).decode().strip()
        return output
    except subprocess.CalledProcessError as e:
        print(f"Error retrieving current version: {e}")
        exit(1)

def get_latest_version():
    """Fetch the latest openSUSE Leap version from endoflife.date API."""
    try:
        response = requests.get('https://endoflife.date/api/v1/products/opensuse/')
        response.raise_for_status()
        data = response.json()
        versions = data.get('versions', [])
        if not versions:
            print("No version information available from API.")
            exit(1)
        # Find the version with the latest release date
        latest_version = max(versions, key=lambda x: x.get('releaseDate', ''))['version']
        return latest_version
    except requests.RequestException as e:
        print(f"Error fetching latest version: {e}")
        exit(1)

def version_tuple(version):
    """Convert version string to tuple for comparison."""
    return tuple(map(int, version.split('.')))

def main():
    # Get current and latest versions
    current_version = get_current_version()
    latest_version = get_latest_version()

    print(f"Current openSUSE Leap version: {current_version}")
    print(f"Latest openSUSE Leap version: {latest_version}")

    # Compare versions
    if version_tuple(latest_version) > version_tuple(current_version):
        print(f"A new version is available: {latest_version}")
        confirm = input("Do you want to update to this version? (y/n): ").strip().lower()
        if confirm == 'y':
            print(f"Starting update to openSUSE Leap {latest_version}...")
            try:
                subprocess.run(['sudo', 'zypper', '--releasever', latest_version, 'dup'], check=True)
                print("Update completed. You may need to reboot your system.")
            except subprocess.CalledProcessError as e:
                print(f"Update failed: {e}")
        else:
            print("Update cancelled.")
    else:
        print("Your system is already on the latest version.")

if __name__ == "__main__":
    main()