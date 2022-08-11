#!/usr/bin/python3
  
import json

name = "FlightOfTheBumbleBee "
symbol = "FBEE"

description = "Issued to celebrate the launch of the BEECapital APP, with a total of 10,000 pieces, each NFT style is unique and can be used as a status symbol in the BEECapital APP."

image = ""

Background = {"bee":"Bee", "shandian":"Lightning", "keji":"Technology", "rainbow":"Rainbow", 
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

Necklace = {"1":"Gold", "2":"Pearl", "3":"Diamond", "8":"Nothing"}


attribute_map = {"Background":Background, "Face":Face, "Body":Body, "Head":Head, "Tentacle":Tentacle, 
        "Eye":Eye, "Glasses":Glasses, "Bubble":Bubble, "Necklace":Necklace}

attribute_map_key = {"Background":"Background", "face":"Face", "shenti":"Body", "tou":"Head", "fat":"Tentacle", 
        "eye":"Eye", "glass":"Glasses", "paopao":"Bubble", "xianglian":"Necklace"}

for i in range(1, 2):
    print("hehe")
    filename = str(i) + ".json"
    new_dict = {}
    with open(filename) as f:
        load_dict = json.load(f)
        new_dict["name"] = name + " #" + str(i)
        new_dict["symbol"] = symbol
        new_dict["description"] = description
        new_dict["label"] = "#F" + str(i)
        new_dict["image"] = image + str(i) + ".json"
        attribute_list = []
        for attribute in load_dict["attributes"]:
                error_key = attribute["trait_type"]
                print("error_key " + error_key)
                print("attribute_map_key[error_key] " + attribute_map_key[error_key])
                print("attribute_map[attribute_map_key[error_key]] " , attribute_map[attribute_map_key[error_key]])
                
                attribute["value"] = attribute_map[attribute_map_key[error_key]][attribute["value"]]
                attribute["trait_type"] = attribute_map_key[error_key]
                attribute_list.append(attribute)
        new_dict["attributes"] = attribute_list

        with open("./record.json","w") as dump_f:
             json.dump(new_dict, dump_f)