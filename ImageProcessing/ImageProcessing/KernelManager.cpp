#include "KernelManager.h"
#include "kernel.cuh"


KernelManager::KernelManager()
{
}


KernelManager::~KernelManager()
{
}

void KernelManager::runKernels(int iterations)
{
	runKernel(iterations);
}
