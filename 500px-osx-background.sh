#!/bin/bash

# 
# 500px-osx-background
# Author: Enrico Cambiaso
# Email: enrico.cambiaso[at]gmail.com
# GitHub project URL: https://github.com/auino/500px-osx-background
# 

# --- --- --- --- ---
# CONFIGURATION BEGIN
# --- --- --- --- ---

# set to 0 if you want to use (also) portrait photos as background
ONLY_LANDSCAPE_MODE=1

# background image file path
IMG_FILE="/tmp/500px-osx-background.png"

# specify feed source type; available options: user, search, popular, upcoming, fresh, editors
SRC_TYPE="editors"

# enable the single feed you prefer
# feeds information are available at https://support.500px.com/hc/en-us/articles/204910987-What-RSS-feeds-are-available-

# images of a specific user
if [ "$SRC_TYPE" == "user" ]; then
	USER="auino"
	FEED="https://500px.com/$USER/rss"
fi

# images from a search
if [ "$SRC_TYPE" == "search" ]; then
	SEARCH_QUERY="cat"
	CATEGORIES="Animals"
	SORT="newest"
	FEED="https://500px.com/search.rss?q=${SEARCH_QUERY}&type=photos&categories=${CATEGORIES}&sort=${SORT}"
fi

# popular feed
if [ "$SRC_TYPE" == "popular" ]; then
	FEED="https://500px.com/popular.rss"
fi

# upcoming feed
if [ "$SRC_TYPE" == "upcoming" ]; then
	FEED="https://500px.com/upcoming.rss"
fi

# fresh feed
if [ "$SRC_TYPE" == "fresh" ]; then
	FEED="https://500px.com/fresh.rss"
fi

# editors' choice feed
if [ "$SRC_TYPE" == "editors" ]; then
	FEED="https://500px.com/editors.rss"
fi

# --- --- --- --- ---
#  CONFIGURATION END
# --- --- --- --- ---

# temp file for feed
RSSTMP=$(mktemp /tmp/500px-osx-background.rss.XXXXXXXX)

# randomize string
RANDOMIZER=$(date +%s)

# getting feed from 500px
curl -s -o "$RSSTMP" "$FEED"
IMAGE_PAGES=$(xmllint --noout --shell <<< "cat //item/link/text()" "$RSSTMP" | sed '/^[-/>[:space:]]*$/d' | shuf)
rm "$RSSTMP"

# cycling until a "good" image if found
for image_page in $IMAGE_PAGES; do
	IMG=$(curl -s -L "$image_page" | xmllint --html --xpath "string(//meta[@property='og:image']/@content)" - 2>/dev/null)

	IMGTMP=$(mktemp /tmp/500px-osx-background.png.XXXXXXXX)

	# getting image data from url
	curl -s "$IMG" -o "$IMGTMP"

	# getting image dimensions
	IMG_W=`sips -g pixelWidth "$IMGTMP" | tail -n 1 | awk '{print $2}'`
	IMG_H=`sips -g pixelHeight "$IMGTMP" | tail -n 1| awk '{print $2}'`
	echo "Image size is ${IMG_W} x ${IMG_H}"

	# checking if image is "good"
	if [ ! $ONLY_LANDSCAPE_MODE ] || [ $IMG_W -gt $IMG_H ]; then
		break
	fi

	rm "$IMGTMP"
	IMGTMP=
done

if [ -n "$IMGTMP" ]; then
	mv "$IMGTMP" "$IMG_FILE"

	# setting image as background
	echo "Setting downloaded image as background"
	osascript -e 'tell application "System Events" -- activate' -e 'end tell'
	osascript -e 'tell application "System Events" to set picture of every desktop to ("'$IMG_FILE'" as POSIX file as alias)'
else
	echo "No image found"
fi
