// ============================================
// Skills Data
// ============================================

export const skills = {
  frontend: [
    { name: 'JavaScript', level: 'Advanced' },
    { name: 'TypeScript', level: 'Intermediate' },
    { name: 'React', level: 'Advanced' },
    { name: 'Next.js', level: 'Intermediate' },
    { name: 'Three.js', level: 'Intermediate' },
    { name: 'HTML/CSS', level: 'Advanced' },
    { name: 'GSAP', level: 'Intermediate' },
    { name: 'Tailwind CSS', level: 'Advanced' },
  ],
  backend: [
    { name: 'Spring Boot', level: 'Intermediate' },
    { name: 'Express', level: 'Advanced' },
    { name: 'Python', level: 'Intermediate' },
    { name: 'Java', level: 'Intermediate' },
    { name: 'PostgreSQL', level: 'Intermediate' },
    { name: 'MongoDB', level: 'Intermediate' },
    { name: 'REST APIs', level: 'Advanced' },
  ],
  tools: [
    { name: 'Git', level: 'Advanced' },
    { name: 'Docker', level: 'Intermediate' },
    { name: 'VS Code', level: 'Advanced' },
    { name: 'Figma', level: 'Intermediate' },
    { name: 'IntelliJ IDEA', level: 'Intermediate' },
    { name: 'Vercel', level: 'Advanced' },
    { name: 'GitHub Actions', level: 'Intermediate' },
  ],
};

// ============================================
// Contact Details
// ============================================

// Add each category's Baidu Netdisk and Q&A URLs when available.
export const contactDetails = {
  contact: {
    title: '联系我们',
    description: [
      '团队向河北工业大学全体同学发出邀请，真诚希望志同道合的朋友加入我们。',
      '现需：\n软件开发两人\n美术设计一人\n各学院负责人各一人',
      '欢迎各位HEBUTer联系我们！！\n共赴星辰，能创未来，\nHEBUT先进空天国家重点研究中心再次欢迎你的到来！！',
      '联系方式：\nqq：732414720\n团队邮箱：hebutxjkt@163.com',
    ].join('\n\n'),
    stack: [],
    baiduUrl: null,
    qaUrl: null,
  },
  submissions: {
    title: '河工开物-征稿公告',
    description: [
      '优秀的平台，离不开每一位工大人的共同建设与用心守护！',
      '现面向全体工大人长期征集优质稿件，期待你的期末重点、校园故事、优秀文章在这里被更多人看见！',
      '投稿邮箱：hebutxjkt@163.com',
      '投稿时，请将邮件主题标注为“投稿名称—稿件类型”，并附上Word可修改版稿件，同时留下作者姓名（可匿名）及联系方式，便于后续沟通。',
      '稿件一经采用，可获得39—69元稿费；同一作者累计中稿超过3次后，此后每次中稿还将额外获得10元“优质作者赏金”！',
      '用文字记录工大故事，用热爱传递青春力量。期待每一份真诚表达，也期待与你一起，让这个属于工大人的平台更加精彩！',
    ].join('\n\n'),
    stack: [],
    baiduUrl: null,
    qaUrl: null,
  },
  opensource: {
    title: '开源项目',
    description: '',
    sections: [
      {
        title: '开源项目1-浩正暖通',
        paragraphs: [
          'Excel内置插件，一键完成冷热负荷计算、空气处理计算、设备选型和焓湿图。',
          '软件致力于CAD、各暖通规范、Excel一体集成，以最少的屏幕点击与切屏完成暖通项目。',
          '本人和另一位同学应用该软件demo版本，最终获得了空气调节课设唯二最高分，所以将软件开源，希望能帮助到更多人。',
        ],
      },
      {
        title: '开源项目2-FC26补丁-23级建环纪念',
        paragraphs: [
          '3年多的河工大求学生涯，感谢遇到的每一位共同学习进步的同学。',
          '我通过脸补扫描建模技术，将专业所有的同学做进了游戏里面，希望把美好的记忆永远收藏。同时，补丁中包含几个我的好友作为彩蛋哈哈（Guess who’s included😜）。',
          '再次感谢每一位参与的同学的大力支持。同时，我将FC杯赛补丁、真实转播补丁、球鞋球衣补丁、打补丁需要用到的LE和FMM也放进了网盘链接。',
          '在此同时，感谢其他开源作者为FC生态的贡献，希望给大家崭新的线上足球体验！！',
        ],
      },
    ],
    stack: ['Excel', 'MATLAB', 'REFPROP', 'Python', 'Godot', 'Live Editor', 'FIFA Manager Editor'],
    baiduUrl: null,
    qaUrl: null,
  },
};

// ============================================
// Projects Data
// ============================================

export const projects = [
  {
    title: 'Thermodynamic and Control System of Carnot Battery',
    description: '针对可逆型卡诺电池，建立数学模型，通过热力学与控制算法优化，给出各工况下的最优解及参数。',
    stack: ['MATLAB', 'REFPROP', 'C++', 'Python', 'Solidwork', 'Autoshop'],
    githubUrl: null,
    liveUrl: null,
  },
  {
    title: 'Rural Housing Optimization Design Platform',
    description: '',
    stack: ['Python', 'C++', 'Java', 'Godot'],
    githubUrl: null,
    liveUrl: null,
  },
  {
    title: 'Curated Repository of Study Resources',
    description: '课程刷题、期末重点、优秀文章，更适合河工人的学习宝典。',
    stack: ['C++', 'Godot', '全学科'],
    githubUrl: null,
    liveUrl: null,
  },
  {
    title: 'Above The Conquerors',
    description: '纵横世界，身临其境中世纪文明战争与传说，即时战略新作。',
    stack: ['C++', 'Godot', 'Java', 'Blender', 'Python', 'Photoshop'],
    githubUrl: null,
    liveUrl: null,
  },
  {
    title: '新项目正在路上...',
    description: '',
    stack: [],
    githubUrl: null,
    liveUrl: null,
    placeholder: true,
  },
  {
    title: '新项目正在路上...',
    description: '',
    stack: [],
    githubUrl: null,
    liveUrl: null,
    placeholder: true,
  },
  // {
  //   title: 'Chat Application',
  //   description: 'Real-time messaging application with end-to-end encryption, file sharing, group chats, and online status indicators.',
  //   stack: ['React', 'Firebase', 'WebRTC', 'Node.js'],
  //   githubUrl: 'https://github.com/',
  //   liveUrl: 'https://example.com',
  // },
  // {
  //   title: 'DevOps Monitor',
  //   description: 'A system monitoring dashboard for tracking server health, deployment pipelines, container metrics, and automated alerting.',
  //   stack: ['Python', 'Docker', 'Grafana', 'REST API'],
  //   githubUrl: 'https://github.com/',
  //   liveUrl: null,
  // },
];
