/**
 * Seed boat_config collection in WeChat cloud DB
 * Run once: npx ts-node --skip-project scripts/seed-boat-config.ts
 * 
 * Or via curl:
 * curl -X POST http://localhost:3000/api/config/boats/update \
 *   -H "Content-Type: application/json" \
 *   -d '{"password":"YOUR_ADMIN_PASSWORD","boats":[{"id":"kingfisher","name":"Kingfisher 3025","length":"30","maxPassengers":8,"charterPrice":1700,"perPersonPrice":240,"deposit":500,"sharedDeposit":100,"image":"/images/kingfisher.jpg","active":true},{"id":"axopar","name":"Axopar 37 XC","length":"37","maxPassengers":10,"charterPrice":2200,"perPersonPrice":240,"deposit":500,"sharedDeposit":100,"image":"/images/axpor.jpg","active":true}]}'
 */

const BOATS = [
  {
    id: 'kingfisher',
    name: 'Kingfisher 3025',
    length: '30',
    maxPassengers: 8,
    charterPrice: 1700,
    perPersonPrice: 240,
    deposit: 500,
    sharedDeposit: 100,
    image: '/images/kingfisher.jpg',
    active: true,
    features: ['Garmin GPS鱼探仪', '独立卫生间', 'Pre-Flex船体技术'],
    description_zh: '30英尺加拿大制造的铝制专业海钓船，搭载500马力雅马哈发动机。',
    description_en: '30ft Canadian-built aluminum fishing boat with 500HP Yamaha.',
  },
  {
    id: 'axopar',
    name: 'Axopar 37 XC',
    length: '37',
    maxPassengers: 10,
    charterPrice: 2200,
    perPersonPrice: 240,
    deposit: 500,
    sharedDeposit: 100,
    image: '/images/axpor.jpg',
    active: true,
    features: ['Garmin GPS鱼探仪', '独立卫生间', '全封闭加热驾驶室'],
    description_zh: '37英尺获奖芬兰设计豪华运动船，全封闭加热驾驶室。',
    description_en: '37ft award-winning Finnish luxury sport boat with heated cabin.',
  },
];

console.log('Seed boat_config via API:');
console.log('');
console.log('curl -X POST http://localhost:3000/api/config/boats/update \\');
console.log('  -H "Content-Type: application/json" \\');
console.log(`  -d '${JSON.stringify({ password: 'YOUR_ADMIN_PASSWORD', boats: BOATS })}'`);
