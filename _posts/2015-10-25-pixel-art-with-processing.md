---
layout: post
title: "Pixel Art with Processing"
description: "Describes my first project with the Processing language in creating a pixel art image."
category: Post
tags: [Processing]
image:
  feature: layout-posts.jpg
comments: false
---

This brief post talks about my first attempt at creating *art* using the [Processing](https://processing.org) language.

<!-- more -->

Lately I have been reading **The Sparkfun Guide to Processing** by *Derek Runberg* in order to learn the Processing language. I am currently investigating the use of this language to generate a photo slideshow program that can be used with a Raspberry Pi computer as a DIY digial photo frame. From the *Processing* languages website:

>Processing is a flexible software sketchbook and a language for learning how to code within the context of the visual arts. Since 2001, Processing has promoted software literacy within the visual arts and visual literacy within technology. There are tens of thousands of students, artists, designers, researchers, and hobbyists who use Processing for learning and prototyping.

Following along with the book, my first project was to create some pixel art. Lately I have been intrigued by the Omega, &#003A9;, symbol so I thought that would be an ideal start.

The first step was to layout the drawing on graph paper which helped me visualize the image as well as provide an easy coordinate system reference. The origin of a Processing sketch starts at 0,0 which is in the upper left corner. The *x-axix* increases to the right of the origin, and the *y-axis* increases down from the origin.

The image below shows the coordinate system as well as the numbers assigned to each block that will be rendered in the Processing sketch.

![Hand Image](/images/posts/pixel-art-with-processing-01.png)

A Processing sketch at a minimum consists of a *setup* function and a *draw* function. The setup function is designed to provide one-time setup processing before the main draw function starts. The draw function is executed sixty times a second to handle the main animations.

> In my case, I could have ended the draw function with a call to the *noLoop* function because I am producing a static drawing.

The Processing code is shown below and is generally self-explanatory from the embedded comments. The numbers in the parentheses in the comments identify the numbered shapes on the original graph paper.

```
// On screen drawing is set to 10x original size, by
// multiplying all size and location coordinates from
// the graph paper by 10.

void setup()
{
  // Setup codes goes here and only runs once  
  size(420,330);
  background(255,255,255);  // White background
}

void draw()
{
  // Draw code goes here and runs 60 times per second

  // Draw highlights
  stroke(137,142,19);  // Off yellow border outline
  fill(237,227,17);    // Yellow

  rect(120,30,10,10);  // Highlight (1)
  rect(130,40,10,10);
  rect(140,50,10,10);
  rect(150,60,10,10);

  rect(290,30,10,10);  // Highlight (2)
  rect(280,40,10,10);
  rect(270,50,10,10);
  rect(260,60,10,10);

  rect(170,20,10,10);  // Highlight (3)
  rect(180,30,10,10);
  rect(190,40,10,10);

  rect(240,20,10,10);  // Highlight (4)
  rect(230,30,10,10);
  rect(220,40,10,10);

  rect(80,120,10,10);  // Highlight (5)
  rect(90,120,10,10);
  rect(100,120,10,10);
  rect(110,120,10,10);

  rect(300,120,10,10); // Highlight (6)
  rect(310,120,10,10);
  rect(320,120,10,10);
  rect(330,120,10,10);

  rect(110,160,10,10); // Highlight (7)
  rect(100,170,10,10);
  rect(90,180,10,10);
  rect(80,190,10,10);

  rect(300,160,10,10); // Highlight (8)
  rect(310,170,10,10);
  rect(320,180,10,10);
  rect(330,190,10,10);

  // Draw omega shape
  noStroke();          // No border outline
  fill(132,203,70);    // Green

  rect(110,250,60,10); // Shape (9)
  rect(170,240,10,10); // Shape (10)
  rect(180,230,10,10); // Shape (11)
  rect(190,200,10,30); // Shape (12)
  rect(180,190,10,10); // Shape (13)
  rect(170,180,10,10); // Shape (14)
  rect(160,170,10,10); // Shape (15)
  rect(150,160,10,10); // Shape (16)
  rect(140,150,10,10); // Shape (17)
  rect(130,110,10,40); // Shape (18)
  rect(140,100,10,10); // Shape (19)
  rect(150,90,10,10);  // Shape (20)
  rect(160,80,10,10);  // Shape (21)
  rect(170,70,10,10);  // Shape (22)
  rect(180,60,60,10);  // Shape (23)
  rect(240,70,10,10);  // Shape (24)
  rect(250,80,10,10);  // Shape (25)
  rect(260,90,10,10);  // Shape (26)
  rect(270,100,10,10); // Shape (27)
  rect(280,110,10,40); // Shape (28)
  rect(270,150,10,10); // Shape (29)
  rect(260,160,10,10); // Shape (30)
  rect(250,170,10,10); // Shape (31)
  rect(240,180,10,10); // Shape (32)
  rect(230,190,10,10); // Shape (33)
  rect(220,200,10,30); // Shape (34)
  rect(230,230,10,10); // Shape (35)
  rect(240,240,10,10); // Shape (36)
  rect(250,250,60,10); // Shape (37)
}
```

The original code resulted in a direct translation of the graph paper into the code, resulting in an image that was only roughly 35 x 25 pixels high. This is a good size to use as a sprite for a game but it too small to be used for *art*. The solution was to multiple all size and position coordinates by 10, which increased the original document 10x times. For example if a rectangle was originally specified as **Rect(14,10,1,1)** then increasing it by ten times would result in **Rect(140,100,10,10)** instead.

The final image is shown below.

![Rendered Image](/images/posts/pixel-art-with-processing-02.png)

I hope this little introduction into the *Processing* language has got you excited about what it can do. I was very satisfied the ease of creating this piece of *art* and look forward into exploring more of the language for my photo slideshow.
