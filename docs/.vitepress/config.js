export default {
  title: 'New API',
  description: 'Next-Generation LLM Gateway and AI Asset Management System',
  lang: 'zh-CN',
  
  themeConfig: {
    logo: '/logo.png',
    nav: [
      { text: '首页', link: '/' },
      { text: '用户指南', link: '/guide/' },
      { text: 'API 参考', link: '/api/' },
    ],
    sidebar: {
      '/guide/': [
        {
          text: '快速开始',
          items: [
            { text: '概述', link: '/guide/' },
            { text: '账户注册与登录', link: '/guide/getting-started' },
            { text: '生成 API Token', link: '/guide/token' },
          ]
        },
        {
          text: '主要功能',
          items: [
            { text: '令牌管理', link: '/guide/token-management' },
            { text: '模型选择', link: '/guide/models' },
            { text: '用户分组', link: '/guide/groups' },
            { text: '余额管理', link: '/guide/balance' },
            { text: '聊天功能', link: '/guide/chat' },
            { text: '操练场', link: '/guide/playground' },
          ]
        },
        {
          text: '常见操作',
          items: [
            { text: '常见问题', link: '/guide/faq' },
            { text: '最佳实践', link: '/guide/best-practices' },
            { text: '故障排查', link: '/guide/troubleshooting' },
          ]
        }
      ],
      '/api/': [
        {
          text: 'API 文档',
          items: [
            { text: 'API 介绍', link: '/api/' },
            { text: '身份认证', link: '/api/authentication' },
            { text: '用户 API', link: '/api/user' },
            { text: '模型 API', link: '/api/models' },
            { text: '聊天 API', link: '/api/chat' },
            { text: '令牌 API', link: '/api/tokens' },
            { text: '账单 API', link: '/api/billing' },
            { text: '错误处理', link: '/api/errors' },
            { text: '代码示例', link: '/api/examples' },
          ]
        }
      ]
    },
    footer: {
      message: 'Released under the AGPL License.',
      copyright: 'Copyright © 2024 QuantumNous'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/QuantumNous/new-api' }
    ]
  }
}
