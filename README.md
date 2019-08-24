# 500px-osx-background
Easily set your Mac background to a random image on 500px website

### Description ###

This script allows you to dynamically change your macOS background, taking images from [500px](https://500px.com).

### Installation ###

 1. Clone the repository:

    ```
    git clone https://github.com/auino/500px-osx-background.git
    ```

 2. Configure the script, by opening it and setting configuration data as preferred

 3. Optionally, you can test the correct working of the script, by opening the Terminal app and running the following command:

    ```
    sh 500px-osx-background.sh
    ```

### Scheduling with crontab ###


 1. Put the script on your crontab, by opening the Terminal app and running the following command:

    ```
    crontab -e
    ```

 2. Now you have to append the following line (press `i` button to insert data):

    ```
    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
    
    00 12 * * * sh /directory_path/500px-osx-background.sh
    ```

    where `/directory_path/` identifies the path of the directory containing the script (to be configured as value of the `$DIR` directory on the script), while `00 12` specifies the program has to be called every day at noon.
    setting the PATH is required to allow us to use user binaries

 2. Hit `:wq` to close, saving the file

### Scheduling with launchd ###

1. Create a file at `~/Library/LaunchAgents/500px-osx-background.agent.plist`
2. Enter the following to schedule it to run 12pm daily

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>500px-osx-background</string>
		<key>ProgramArguments</key>
		<array>
			<string>/bin/sh</string>
			<string>/path/to/500px-osx-background.sh</string>
		</array>
		<key>EnvironmentVariables</key>
		<dict>
			<key>PATH</key>
			<string>/bin:/usr/bin:/usr/local/bin</string>
		</dict>
		<key>StartCalendarInterval</key>
		<dict>
			<key>Hour</key>
			<integer>12</integer>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
		<key>StandardErrorPath</key>
		<string>/tmp/500px-osx-background.log</string>
	</dict>
</plist>
```

3. Testing using

````
$ launchctl load ~/Library/LaunchAgents/500px-osx-background.agent.plist 
$ launchctl start 500px-osx-background
````

### Notes ###

In order to immediately set the new background, the `Dock` program has to be killed.
If you don't want to kill it, you can comment the relative line on the script.

It's also available a [Reddit version](https://github.com/auino/reddit-macos-background) of this program, with support to [Gnome](https://www.gnome.org) based Linux systems.

### External contributions ###

 * Thanks to [theiwaz](https://github.com/theiwaz) for his suggestions on multi monitor support
 * Thanks to [miladkdz](https://github.com/miladkdz) for his suggestions on macOS Sierra support
 * Thanks to [vitovalov](https://github.com/vitovalov) for his better implementation of the background change procedures
 * Thanks to [ctissier](https://github.com/ctissier) for the randomization trick to solve macOS cache issues
 * Thanks to [duongvu89](https://github.com/duongvu89) for the provided bug fixes
 * Thanks to [stefanskotte](https://github.com/stefanskotte) for the provided bug fix

### Contacts ###

You can find me on Twitter as [@auino](https://twitter.com/auino).
