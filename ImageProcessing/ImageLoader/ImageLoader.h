#pragma once
struct Pixel
{
	unsigned char r = 0;
	unsigned char g = 0;
	unsigned char b = 0;
};


class ImageLoader
{
private:
	ImageLoader();
	~ImageLoader();
public:
	int width, height, channels;
	Pixel* pixels = nullptr;
	static ImageLoader* getInstance();
	void loadImage(const char* filename);
	void writeImage();
};

