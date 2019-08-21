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

# script directory (without final '/' slash)
DIR="/Users/paul/Projects/other/500px-osx-background"

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

# randomize string
RANDOMIZER=$(date +%s)

# getting feed from 500px
curl -s -o rss.xml "$FEED"
IMAGE_PAGES=$(xmllint --noout --shell <<< "cat //item/link/text()" rss.xml | sed '/^[-/>[:space:]]*$/d' | shuf)

# cycling until a "good" image if found
FOUND=0
for image_page in $IMAGE_PAGES; do
	IMG=$(curl -s -L "$image_page" | xmllint --html --xpath "string(//meta[@property='og:image']/@content)" - 2>/dev/null)

	# deleting previous imgs
	rm $DIR/500px_img*

	# getting image data from url
	curl -s "$IMG" -o $DIR/500px_img_$RANDOMIZER.png

	# getting image dimensions
	IMG_W=`sips -g pixelWidth $DIR/500px_img_$RANDOMIZER.png|tail -n 1|awk '{print $2}'`
	IMG_H=`sips -g pixelHeight $DIR/500px_img_$RANDOMIZER.png|tail -n 1|awk '{print $2}'`
	echo "Image size is ${IMG_W} x ${IMG_H}"

	# checking if image is "good"
	if [ ! $ONLY_LANDSCAPE_MODE ] || [ $IMG_W -gt $IMG_H ]; then
		FOUND=1
		break
	fi

	break
done

if [ $FOUND ]; then
	# setting image as background
	echo "Setting downloaded image as background"
	osascript -e 'tell application "System Events" -- activate' -e 'end tell'
	osascript -e 'tell application "System Events" to set picture of every desktop to ("'$DIR'/500px_img_'$RANDOMIZER'.png" as POSIX file as alias)'
else
	echo "No image found"
fi
