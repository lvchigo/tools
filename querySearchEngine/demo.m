function demo

clear all;clc;

rt_dir = pwd;
db_dir = '/home/chigo/image/img_download';
image_count = 5000;

query_list_bak = { ...
'骑马' '喂鸟' '遛狗' '斗牛' '牛耕地' '养猫'  '喂熊猫' '喂兔子' '喂马' '喂猫' '喂羊' '喂牛' '喂狗'...
'化妆品 logo' '品牌 logo' '背包 旅行' '背包 上学' '打球' '踢球'  '玩球' '读书' '看书' '看表' '拿杯子' '喝水' '戴眼镜' '弹吉他'...
'戴帽子' '戴首饰' '玩玩偶' '送毛绒玩具' '穿鞋'  '玩球' '读书' '看书' '看表' '拿杯子' '喝水' '戴眼镜' '弹吉他'...
'拿相机' '拿手机' '鼠标套装' '办公室电脑' '办公桌电脑' '敲键盘的人'  '敲键盘' '玩手机' '玩相机' '办公桌显示器' '笔记本电脑' '用笔记本电脑' '玩笔记本电脑' '玩ipad'...
'玩平板' '买床' '卧室' '餐厅' '修盆栽'  '买盆栽' '花鸟市场' '客厅' '厨房'...
'野外烧烤' '自助烧烤' '吃烧烤' '吃蛋糕' '吹蛋糕蜡烛' '过生日'  '喝咖啡' '拉花咖啡' '拉花咖啡表演' '喝茶' '做饭' '做饭的人' '自助餐' '摆菜台' '买水果'...
'水果拼盘' '水果摊' '吃火锅' '一家人吃火锅' '吃冰淇淋'  '吃雪糕' '吃批萨' '一家人吃批萨' '吃寿司' '做寿司' '寿司拼盘'...
'飞机场' '飞机场登机' '飞行特技' '骑自行车' '骑行' '自行车比赛'  '赛船' '坐船' '赛艇' '公交停车场' '公交维修站' '停车场' '高峰路段现场' '坐摩托车' '骑摩托车'...
'高峰路段骑电动' '火车事故' '火车头合影' '火车' '动漫贴纸'...
};

query_list_logo = { ...
'阿迪达斯三叶草外套' '阿迪达斯三叶草板鞋' '阿迪达斯三叶草logo'...
'chanel包包' 'chanel香水' 'chanellogo' 'chanel壁纸' 'NIKE鞋' 'NIKE包' 'NIKE服饰' 'NIKE帽子' 'AirJordan' 'airjordan壁纸'  'airjordanlogo'...
'NewBalance鞋' 'NewBalance包' 'newbalance帽子' 'Adidas鞋' 'Adidas服饰' 'Adidas包' 'Adidas帽子' 'louisvuitton包' 'louisvuittonlogo' 'louisvuitton官网'...
'vans鞋' 'vanslogo' 'vans官网' 'prada包' 'pradalogo'  'prada官网' 'BabyMilologo' 'BabyMilo服饰' 'BabyMilo配饰' 'hermeslogo' 'hermes皮带' 'hermes丝巾'...
'converse帽子' 'converse鞋' 'converse包' 'converselogo' 'givenchylogo' 'givenchy包'  'givenchy香水' 'givenchy打火机' 'MCMlogo' 'mcm包'...
'YSLlogo' 'ysl包' 'ysl香水' 'Supremelogo' 'Supreme服饰' 'Supreme帽子' 'kenzo虎头' 'kenzo卫衣'  'coach包' 'coachlogo' 'PaulFrank' 'PaulFrank服饰' 'PaulFrank配饰'...
};

query_list = { ...
'michaelkorslogo' 'michaelkors包' 'CommedesGarconslogo' 'CommedesGarcons衣服' 'Bapelogo' 'Bape服饰' 'Bape包' 'juicycouturelogo' 'juicycouture套装' 'juicycouture香水'...
'李维斯logo' '李维斯牛仔裤' '李维斯包' 'versacelogo' 'versace香水' 'versace标志' 'dolcegabbana香水' 'dolcegabbanalogo' 'puma帽子' 'puma服饰' 'puma鞋' 'puma包'...
'toryburchlogo' 'toryburch包' 'toryburch鞋' 'ralphlaurenlogo' 'ralphlaurenpolo'  'ralphlauren帽子' 'wildfoxcouturelogo' 'evisulogo' 'evisu牛仔裤' 'evisut恤' '不二家' '不二家糖' '不二家logo'...
'安踏鞋' '安踏服饰' '安踏包' '安踏logo' 'Starbuckslogo' 'starbucks杯子'  'starbucks咖啡' 'roxylogo' 'roxy人字拖' 'roxy官网'...
'Rolexlogo' 'rolex手表' 'lanvinlogo' 'lanvin香水' 'lacostelogo' 'lacoste鞋' 'lacoste香水' 'lacoste服饰'  'esteelauderlogo' 'esteelauder化妆品' 'avenelogo' 'avene化妆品'...
'biothermlogo' 'biotherm碧欧泉' 'biotherm化妆品' 'cliniquelogo' 'clinique倩碧' 'clinique化妆品'  '3celogo' '3ce唇膏' '3ce眼影'...
'appletv' 'apple电脑' 'applelogo' 'appleair' 'HelloKitty鞋' 'hellokitty鞋官网' 'kissme睫毛膏' 'kissme化妆品'  '麦当劳food' '麦当劳logo' 'kfclogo' 'kfcfood'...
'nuxelogo' 'nuxe化妆品' 'nuxe面膜' 'nuxe眼霜' 'haagendazslogo' 'haagendazsicecream' 'haagendazs月饼' 'viviennewestwoodlogo'  'viviennewestwood包' 'viviennewestwood手表' 'viviennewestwood眼镜'...
'vichylogo' 'vichy面膜' 'vichy眼霜' 'vichy化妆品' 'Longineslogo' 'longines浪琴' 'longines手表'...
};

for i = 1:length(query_list)
query = query_list{i};
urls = queryAll(query, image_count);
query_dir = [db_dir, '/', query];
mkdir(query_dir);
sh_file = [query_dir, '/download.sh'];
urls2wget(urls, sh_file);
dos(['cd ', query_dir, '&& bash ', sh_file, ' &']);
end

fprintf('Download Img End!!');

clear all;clc;
