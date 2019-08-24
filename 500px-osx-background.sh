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

# directory to save background image (without trailing '/' slash)
IMG_DIR="/tmp/Wallpaper"

# the image name prefix
IMG_PREFIX="500px-osx-background"

# specify feed source type; available options: user, popular, upcoming, fresh, editors
SRC_TYPE="popular"

# enable the single feed you prefer
# feeds information are available at https://support.500px.com/hc/en-us/articles/204910987-What-RSS-feeds-are-available-
# search rss seems to be unavailable anymore (404)

# images of a specific user
if [ "$SRC_TYPE" == "user" ]; then
	USER="auino"
	FEED="https://500px.com/$USER/rss"
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
rss_temp_path=$(mktemp /tmp/500px-osx-background.rss.XXXXXXXX)

# getting feed from 500px
curl -s -o "$rss_temp_path" "$FEED"
photo_ids=$(xmllint --noout --shell <<< "cat //item/link/text()" "$rss_temp_path" | awk -F'/' '{print $5}' | shuf)
rm "$rss_temp_path"

# cycling until a "good" image if found
for photo_id in $photo_ids; do

	# call the api to get the image url
	image_url=$(curl -s -H "x-csrf-token: null" "https://api.500px.com/v1/photos?image_size%5B%5D=2048&ids=$photo_id" \
		| jq -r '.photos[].image_url[0]')
	
	# create a temp file to save the image to
	image_temp_path=$(mktemp /tmp/500px-osx-background.png.XXXXXXXX)

	# getting image data from url
	curl -s "$image_url" -o "$image_temp_path"

	# getting image dimensions
	image_width=`sips -g pixelWidth "$image_temp_path" | tail -n 1 | awk '{print $2}'`
	image_height=`sips -g pixelHeight "$image_temp_path" | tail -n 1| awk '{print $2}'`
	echo "Image size is ${image_width} x ${image_height}"

	# checking if image is "good"
	if [ ! $ONLY_LANDSCAPE_MODE ] || [ $image_width -gt $image_height ]; then
		break
	fi

	# remove temporary image, we aren't using it
	rm "$image_temp_path"
	image_temp_path=
done

if [ -n "$image_temp_path" ]; then
	# remove existing images
	rm "$IMG_DIR/$IMG_PREFIX".*.png

	# move our temporary image to its permanent location
	IMG_PATH="$IMG_DIR/$(mktemp -u $IMG_PREFIX.XXXXXXXX).png"
	echo "Saving image as $IMG_PATH"
	mv "$image_temp_path" "$IMG_PATH"

	# setting image as background
	echo "Setting downloaded image as background"
	osascript -e 'tell application "System Events" -- activate' -e 'end tell'
	osascript -e 'tell application "System Events" to set picture of every desktop to ("'$IMG_PATH'" as POSIX file as alias)'
else
	echo "No image found"
fi
