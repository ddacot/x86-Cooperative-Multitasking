#include <allegro.h>
#include <stdlib.h>
#include <stdio.h>
extern yield();
extern main();

int x = 480, y = 120, radius = 100, color = 0;
MIDI *beep;
void drawCircle(int x, int y, int radius, int color) {
  ellipse(screen, x, y, radius, radius, color);
  if(radius > 10) {
    drawCircle(x + radius/2, y, radius/2,color++);
    yield();
    color++;
    drawCircle(x - radius/2, y, radius/2, color++);
    yield();
    color++;
    drawCircle(x, y + radius/2, radius/2, color++);
    yield();
    color++;
    drawCircle(x, y - radius/2, radius/2, color++);
    yield();
  }

}

 void playSong()
{
    play_midi(beep, TRUE);
    while (1)
     {
      int i = 0;
      for(i=0; i < 500; i++);
      yield();
    }
}
void init_song()
{
  install_timer();
  install_sound(DIGI_AUTODETECT, MIDI_AUTODETECT, NULL);
  beep = load_midi("sound.mid");
}
void init()
{
  allegro_init();
}

void drawGrid()
{
    set_gfx_mode(GFX_AUTODETECT, 640, 480, 0, 0);
    yield();
}

void taskC()
{
  
  set_gfx_mode(GFX_AUTODETECT, 640, 480, 0, 0);
  while(1)
  {
  yield();
  line(screen, 318, 0, 318, 240, 12);
  yield();
  line(screen, 0, 240, 640, 240, 12);
  yield();
  drawCircle(x,y,radius,color++);
  yield();
  } 
}