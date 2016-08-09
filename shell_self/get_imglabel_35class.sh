#find food.barbecue/ -name "*.jpg" >list_food.barbecue.txt
#sed -i 's/.jpg/.jpg 0/g' list_food.barbecue.txt

a=(food.bread food.coffee food.fruit.strawberry food.hamburger food.pizza food.shrimp 
goods.bag goods.bangle goods.bottle goods.camera goods.cosmetics 
goods.drawbar goods.glass goods.guitar goods.laptop 
goods.lipstick goods.manicure goods.pendant goods.phone goods.ring 
goods.SLR goods.watch 
people.lip people.self 
pet.cat.persian pet.dog.golden pet.dog.spotty pet.dog.teddy 
scene.clothingshop scene.desert scene.forest 
scene.sticker scene.street scene.tallbuilding scene.text)

for((i=0;i<35;i++))
 do
  b=${a[$i]}
  echo $b
  find $b -name "*.jpg" >list_$b.txt

  sed -i 's/.jpg/.jpg '${i}' /g' list_$b.txt
done

rm img_train.txt
cat list_*.txt >img_35class_train.txt
rm list_*.txt



