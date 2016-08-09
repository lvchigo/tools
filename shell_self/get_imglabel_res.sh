#cat img_train.txt |grep ".jpg 0" |wc -l

a=(food.barbecue food.bread food.cake food.coffee food.crab 
food.dumpling food.fruit.cherry food.fruit.strawberry food.hamburger food.hotpot 
food.icecream food.pizza food.rice food.shrimp food.steak 
food.sushi goods.airplane goods.bag goods.bangle goods.bottle 
goods.bracelet goods.camera goods.car goods.clothes goods.cosmetics 
goods.drawbar goods.flower goods.glass goods.guitar goods.laptop 
goods.lipstick goods.manicure goods.pendant goods.phone goods.ring 
goods.ship goods.shoe goods.SLR goods.train goods.watch 
people.eye people.friend people.hair people.kid people.lip 
people.self people.street pet.alpaca pet.cat.bambay pet.cat.chis 
pet.cat.persian pet.cat.short pet.cat.siamese pet.dog.bichon pet.dog.Chihuahua 
pet.dog.golden pet.dog.husky pet.dog.pug pet.dog.samoye pet.dog.spotty 
pet.dog.teddy pet.rabbit scene.clothingshop scene.desert scene.forest 
scene.handdrawn scene.highway scene.mountain scene.opencountry scene.sea 
scene.sticker scene.street scene.supermarket scene.tallbuilding scene.text)

echo "**********************"
echo "*******img_train******"
echo "**********************"
for((i=0;i<75;i++))
 do
  b=${a[$i]}
  echo ${i}"-"$b"-";cat img_train.txt |grep ".jpg "${i}"" |wc -l
done

echo "**********************"
echo "*******img_val********"
echo "**********************"
for((i=0;i<75;i++))
 do
  b=${a[$i]}
  echo ${i}"-"$b"-";cat img_val.txt |grep ".jpg "${i}"" |wc -l
done

echo "**********************"
echo "*******img_test*******"
echo "**********************"
for((i=0;i<75;i++))
 do
  b=${a[$i]}
  echo ${i}"-"$b"-";cat img_test.txt |grep ".jpg "${i}"" |wc -l
done




