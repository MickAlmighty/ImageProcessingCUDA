#include "kernel.cuh"
#include <iostream>
#include <ctime>
#include "../ImageLoader/ImageLoader.h"

__global__ void changeColors(Pixel* pixel_dev, int brightness)
{
	//pixel_dev[blockIdx.x].r = 166;
	//int index = blockIdx.x + threadIdx.x;
	int x = blockIdx.x;
	int y = blockIdx.y;
	int offset = x + y * gridDim.x;
	int r = pixel_dev[offset].r + brightness;
	int g = pixel_dev[offset].g + brightness;
	int b = pixel_dev[offset].b + brightness;

	if (r < 0)
		r = 0;
	if (g < 0)
		g = 0;
	if (b < 0)
		b = 0;

	if (r > 255)
		r = 255;
	if (g > 255)
		g = 255;
	if (b > 255)
		b = 255;

	pixel_dev[offset].r = r;
	pixel_dev[offset].g = g;
	pixel_dev[offset].b = b;
}

__global__ void horizontalGaussianBlur(Pixel* pixel_dev)
{
	int x = blockIdx.x;
	int y = blockIdx.y;
	int offset = x + y * gridDim.x;
	static const float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
	int colorCanal = 0;

	colorCanal = pixel_dev[offset].r * weight[0];
	for(int i = 1; i < 5; i++)
	{
		colorCanal += pixel_dev[offset + i].r * weight[i];
		colorCanal += pixel_dev[offset - i].r * weight[i];
	}
	pixel_dev[offset].r = colorCanal;

	colorCanal = pixel_dev[offset].g * weight[0];
	for (int i = 1; i < 5; i++)
	{
		colorCanal += pixel_dev[offset + i].g * weight[i];
		colorCanal += pixel_dev[offset - i].g * weight[i];
	}
	pixel_dev[offset].g = colorCanal;


	colorCanal = pixel_dev[offset].b * weight[0];
	for (int i = 1; i < 5; i++)
	{
		colorCanal += pixel_dev[offset + i].b * weight[i];
		colorCanal += pixel_dev[offset - i].b * weight[i];
	}
	pixel_dev[offset].b = colorCanal;
}

__global__ void verticalGaussianBlur(Pixel* pixel_dev)
{
	int x = blockIdx.x;
	int y = blockIdx.y;
	int offset = x + y * gridDim.x;
	//static int executed = 0;
	static const float weight[5] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };
	int colorCanal = 0;
	//printf("\n Block %d Offset %d Executed %d", blockIdx.x, offset, executed);
	colorCanal = pixel_dev[offset].r * weight[0];
	for (int i = 1; i < 5; i++)
	{
		int index = offset + i * gridDim.x;
		if(index < gridDim.x * gridDim.y)
		{
			colorCanal += pixel_dev[offset + i * gridDim.x].r * weight[i];
		}
		index = offset - i * gridDim.x;
		if (index >= 0)
		{
			colorCanal += pixel_dev[offset - i * gridDim.x].r * weight[i];
		}
	}
	pixel_dev[offset].r = colorCanal;

	colorCanal = pixel_dev[offset].g * weight[0];
	for (int i = 1; i < 5; i++)
	{
		int index = offset + i * gridDim.x;
		if (index < gridDim.x * gridDim.y)
		{
			colorCanal += pixel_dev[offset + i * gridDim.x].g * weight[i];
		}
		index = offset - i * gridDim.x;
		if (index >= 0)
		{
			colorCanal += pixel_dev[offset - i * gridDim.x].g * weight[i];
		}
	}
	pixel_dev[offset].g = colorCanal;


	colorCanal = pixel_dev[offset].b * weight[0];
	for (int i = 1; i < 5; i++)
	{
		int index = offset + i * gridDim.x;
		if (index < gridDim.x * gridDim.y)
		{
			colorCanal += pixel_dev[offset + i * gridDim.x].b * weight[i];
		}
		index = offset - i * gridDim.x;
		if (index >= 0)
		{
			colorCanal += pixel_dev[offset - i * gridDim.x].b * weight[i];
		}
	}
	//executed++;
	pixel_dev[offset].b = colorCanal;
	
}

void runKernel(int iterations)
{
	std::clock_t start;
	double duration;
	start = std::clock();

	ImageLoader* imgLoader = ImageLoader::getInstance();
	int width = imgLoader->width, height = imgLoader->height, channels = imgLoader->channels;
	int size = width * height;
	Pixel *pixels = ImageLoader::getInstance()->pixels;

	Pixel *pixels_dev;
	
	cudaMalloc(&pixels_dev, size * sizeof(Pixel));
	cudaMemcpy(pixels_dev, pixels, size * sizeof(Pixel), cudaMemcpyHostToDevice);

	dim3 grid(width, height);
	
	for (int i = 0; i < iterations; i++)
	{
		horizontalGaussianBlur <<<grid, 1 >>> (pixels_dev);
		verticalGaussianBlur<<<grid,1>>>(pixels_dev);
		changeColors <<<grid, 1>>> (pixels_dev, 12);
		cudaGetLastError();
	}
	cudaMemcpy(pixels, pixels_dev, size * sizeof(Pixel), cudaMemcpyDeviceToHost);
	cudaFree(pixels_dev);

	duration = (std::clock() - start) / (double)CLOCKS_PER_SEC;
	printf("Duration %f", duration);
	
	imgLoader->writeImage();
}
