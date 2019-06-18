#include "pch.h"
#include "ImageLoader.h"
#include "stb_image.h"
#include <cstdlib>
#include "stb_image_write.h"

ImageLoader::ImageLoader()
{
}


ImageLoader::~ImageLoader()
{
	free(pixels);
}

ImageLoader* ImageLoader::getInstance()
{
	static ImageLoader* image_loader = nullptr;
	if(image_loader == nullptr)
	{
		image_loader = new ImageLoader();
	}
	return image_loader;
}

void ImageLoader::loadImage(const char* filename)
{
	unsigned char *image = stbi_load(filename,
		&width,
		&height,
		&channels,
		STBI_rgb);
	
	if(image == nullptr)
	{
		return;
	}

	int size = width * height;
	pixels = (Pixel*) malloc(size * sizeof(Pixel));
	for (int i = 0, j = 0; j < width * height; j++, i = i + channels)
	{
		Pixel p;
		p.r = *(image + i);
		p.g = *(image + i + 1);
		p.b = *(image + i + 2);
		pixels[j] = p;
	}

	stbi_image_free(image);
}

void ImageLoader::writeImage()
{
	stbi_write_jpg("output.jpg", width, height, 3, pixels, 100);
}
