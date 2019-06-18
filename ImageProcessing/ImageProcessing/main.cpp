#include <iostream>
#include "KernelManager.h"
#include "../ImageLoader/ImageLoader.h"

int main(int argc, char* argv[])
{
	std::cout << "You have entered " << argc
		<< " arguments:" << "\n";

	std::string filename = argv[1];
	std::string iterations = argv[2];

	ImageLoader::getInstance()->loadImage(filename.c_str());
	if (ImageLoader::getInstance()->pixels != nullptr)
	{
		KernelManager::runKernels(atoi(iterations.c_str()));
	}
}
	
