#!/usr/bin/python3
  
import json

name = "Flight of the Bumble-bee"

image_pre = ""


BackgroundList = {"bee":"Bee", "shandian":"Lightning", "keji":"Technology", "rainbow":"Rainbow", 
        "1":"Cartoon", "2":"Star", "3":"Rainbow bridge", "4":"Skull", "5":"Pink star", "6":"Pink dot",
        "7":"Glow stick", "8":"Love", "9":"Pink", "10":"Ice-cream", "11":"Milk", "12":"Damsel-fish",
        "13":"Sunflower bee", "14":"Greenery bee", "15":"Fly damsel-fish", "16":"Moon-stars", "17":"Waves ball", "18":"Corrugated star"}

Face = {"shandian":"Lightning", "bee":"Bee", "keji":"Technology", 
        "rainbow":"Rainbow", "1":"Cartoon", "2":"Starry sky", "3":"Night sky", "4":"Magma"}

Body = {"shandian":"Lightning", "bee":"Bee", "keji":"Technology", "rainbow":"Rainbow", "1":"Cartoon", 
        "2":"Starry sky", "3":"Night sky", "4":"Magma"}

Head = {"shandian":"Lightning", "bee":"Bee", "keji":"Technology", "rainbow":"Rainbow", "1":"Cartoon", 
        "2":"Starry sky", "3":"Night sky", "4":"Magma"}

Tentacle = {"shandian":"Lightning", "bee":"Bee", "keji":"Technology", "rainbow":"Rainbow", "1":"Cartoon", 
        "2":"Starry sky", "3":"Night sky", "4":"Magma"}

Eye = {"shandian":"Lightning", "bee":"Bee", "keji":"Technology", "rainbow":"Rainbow", "1":"Money", 
        "2":"Common", "3":"Fun"}

Glasses = {"1":"Ant", "2":"Cupid's arrow","3":"Stripe","4":"Star","5":"Common","6":"Elk","7":"Coconut tree","8":"Nothing",
        "9":"Mosaic","10":"Crown", "11":"Honeycomb", "12":"Bird-star","13":"pig","14":"Evil","15":"Nut"}

Bubble = {"1":"Rainbow","2":"Orange","3":"Red","4":"Blue","5":"Purple","6":"Green","7":"Pink","8":"Tobacco pipe","9":"Cigar"}

Necklace = {"1":"Gold", "2":"Pearl", "3":"Diamond"}

for i in range(0, 10001):
    filename = str(i) + ".json"
    with open(filename) as f:
        
