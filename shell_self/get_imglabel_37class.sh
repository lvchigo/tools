#Merge Label to Cat
a=(pet.cat.bambay pet.cat.chis pet.cat.short pet.cat.siamese)

rm -rf pet.cat.other
mkdir pet.cat.other

for((i=0;i<4;i++))
 do
  b=${a[$i]}
  echo $b
  cp $b/*.jpg pet.cat.other/
done


#Merge Label to Dog
a=(pet.dog.bichon pet.dog.Chihuahua pet.dog.husky pet.dog.pug pet.dog.samoye)

rm -rf pet.dog.other
mkdir pet.dog.other

for((i=0;i<5;i++))
 do
  b=${a[$i]}
  echo $b
  cp $b/*.jpg pet.dog.other/
done


#Get img_text from Label
a=(food.bread food.coffee food.fruit.strawberry food.hamburger food.pizza food.shrimp 
goods.bag goods.bangle goods.bottle goods.camera goods.cosmetics 
goods.drawbar goods.glass goods.guitar goods.laptop 
goods.lipstick goods.manicure goods.pendant goods.phone goods.ring 
goods.SLR goods.watch 
people.lip people.self 
pet.cat.persian pet.dog.golden pet.dog.spotty pet.dog.teddy 
scene.clothingshop scene.desert scene.forest 
scene.sticker scene.street scene.tallbuilding scene.text 
pet.cat.other pet.dog.other)

for((i=0;i<37;i++))
 do
  b=${a[$i]}
  echo $b
  find $b -name "*.jpg" >list_$b.txt

  sed -i 's/.jpg/.jpg '${i}' /g' list_$b.txt
done

rm img_37class_train.txt
cat list_*.txt >img_37class_train.txt
rm list_*.txt
