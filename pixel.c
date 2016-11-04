#include<unistd.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<fcntl.h>
#include<linux/fb.h>
#include<sys/mman.h>

int fbfd = 0;
struct fb_var_screeninfo vinfo;
struct fb_fix_screeninfo finfo;
long int screensize = 0;
int   xRes = 0;
int   yRes = 0; 
char  *fbp = 0;

//-----------------------------------------------
// Get screen buffer memory address
//-----------------------------------------------
int getScreenAddr(){

  int addr;

  // Asegurar de que sea de 16 bits de depth
  int status = system("fbset -depth 16");

  // Open the file for reading and writing
  fbfd = open("/dev/fb0", O_RDWR);
  if (!fbfd) {
    printf("Error: cannot open framebuffer device.\n");
    return(1);
  }

  // Get fixed screen information
  if (ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo)) {
    printf("Error reading fixed information.\n");
  }

  // Get variable screen information
  if (ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo)) {
    printf("Error reading variable information.\n");
  }
  printf("%dx%d,%d bits per pixel\n", vinfo.xres, vinfo.yres, vinfo.bits_per_pixel );

  xRes = vinfo.xres;
  yRes = vinfo.yres;

  // map framebuffer to user memory 
  screensize = finfo.smem_len;

  fbp = (char*)mmap(0, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
  addr = (int)fbp;
  close(fbfd);
  return(addr);
}

void pixel(int addr, int x, int y, unsigned short c)
{
    unsigned int coordenada = x * 2 + y * finfo.line_length;
    *((unsigned short*)(addr + coordenada)) = c;

}
