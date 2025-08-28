# 🚀 Gemini 2.5 Flash Image Preview 快速入门教程

## 📋 目录

- [准备工作](#准备工作)
- [环境配置](#环境配置)
- [第一个示例](#第一个示例)
- [图像分析基础](#图像分析基础)
- [高级功能](#高级功能)
- [常见问题](#常见问题)
- [下一步](#下一步)

## 🛠️ 准备工作

### 1. 获取 API 密钥

首先，你需要获取 Gemini API 的访问密钥：

1. 访问 [Google AI Studio](https://aistudio.google.com/)
2. 登录你的 Google 账户
3. 在左侧菜单中选择 "Get API key"
4. 创建新的 API 密钥
5. 复制并保存你的 API 密钥

### 2. 选择开发环境

你可以选择以下任一环境：

- **Python**: 推荐用于快速原型开发和数据处理
- **JavaScript/Node.js**: 适合 Web 应用和前端集成
- **命令行**: 使用 cURL 进行快速测试和调试

## 🔧 环境配置

### Python 环境配置

#### 安装依赖

```bash
# 创建虚拟环境（推荐）
python -m venv gemini-env
source gemini-env/bin/activate  # Linux/Mac
# 或
gemini-env\Scripts\activate     # Windows

# 安装必要的包
pip install google-generativeai pillow requests
```

#### 配置 API 密钥

```python
import os
import google.generativeai as genai

# 方法 1: 环境变量（推荐）
os.environ['GEMINI_API_KEY'] = 'your-api-key-here'
genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

# 方法 2: 直接配置
genai.configure(api_key='your-api-key-here')
```

### JavaScript 环境配置

#### 安装依赖

```bash
# 使用 npm
npm install @google/generative-ai

# 或使用 yarn
yarn add @google/generative-ai
```

#### 配置 API 密钥

```javascript
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI('your-api-key-here');
```

## 🎯 第一个示例

### Python 示例

```python
import google.generativeai as genai

# 配置 API
genai.configure(api_key='your-api-key-here')

# 创建模型实例
model = genai.GenerativeModel('gemini-2.5-flash-image-preview')

# 分析图像
response = model.generate_content([
    "请描述这张图片",
    "path/to/your/image.jpg"
])

print(response.text)
```

### JavaScript 示例

```javascript
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI('your-api-key-here');
const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-image-preview' });

async function analyzeImage() {
    const imageFile = document.getElementById('imageInput').files[0];
    const prompt = "请描述这张图片";
    
    const result = await model.generateContent([prompt, imageFile]);
    const response = await result.response;
    console.log(response.text());
}

analyzeImage();
```

## 🖼️ 图像分析基础

### 支持的图像格式

- **JPEG/JPG**: 最常用的格式，推荐使用
- **PNG**: 支持透明度的格式
- **WebP**: 现代的高效格式
- **BMP**: 基础位图格式

### 图像要求

- **最大尺寸**: 4096 x 4096 像素
- **文件大小**: 建议小于 20MB
- **编码**: 支持 Base64 和文件路径

### 基础图像分析

```python
def analyze_image_basic(image_path, prompt):
    """基础图像分析函数"""
    try:
        response = model.generate_content([prompt, image_path])
        return {
            'success': True,
            'result': response.text,
            'error': None
        }
    except Exception as e:
        return {
            'success': False,
            'result': None,
            'error': str(e)
        }

# 使用示例
result = analyze_image_basic(
    'cat.jpg',
    '请描述这张图片中的动物特征'
)

if result['success']:
    print(f"分析结果: {result['result']}")
else:
    print(f"分析失败: {result['error']}")
```

### 图像预处理

```python
from PIL import Image
import io

def preprocess_image(image_path, max_size=1024):
    """预处理图像：调整大小和格式"""
    with Image.open(image_path) as img:
        # 转换为 RGB 模式
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # 调整大小（保持宽高比）
        if max(img.size) > max_size:
            img.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
        
        # 保存到内存
        buffer = io.BytesIO()
        img.save(buffer, format='JPEG', quality=85)
        buffer.seek(0)
        
        return buffer

# 使用预处理后的图像
processed_image = preprocess_image('large_image.jpg')
response = model.generate_content([
    "请分析这张图片",
    processed_image
])
```

## 🚀 高级功能

### 1. 批量处理

```python
import os
from pathlib import Path

def batch_analyze_images(image_dir, prompt, output_file=None):
    """批量分析目录中的图像"""
    results = []
    image_extensions = {'.jpg', '.jpeg', '.png', '.webp'}
    
    for image_file in Path(image_dir).glob('*'):
        if image_file.suffix.lower() in image_extensions:
            try:
                response = model.generate_content([prompt, str(image_file)])
                results.append({
                    'filename': image_file.name,
                    'analysis': response.text,
                    'status': 'success'
                })
                print(f"✅ 已分析: {image_file.name}")
            except Exception as e:
                results.append({
                    'filename': image_file.name,
                    'analysis': None,
                    'status': 'error',
                    'error': str(e)
                })
                print(f"❌ 分析失败: {image_file.name}")
    
    # 保存结果
    if output_file:
        import json
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
    
    return results
```

### 2. 多轮对话

```python
def multi_turn_analysis(image_path, questions):
    """多轮图像分析对话"""
    conversation = []
    
    for i, question in enumerate(questions):
        # 构建对话历史
        if i == 0:
            # 第一轮：只包含图像和问题
            response = model.generate_content([question, image_path])
        else:
            # 后续轮次：包含对话历史
            conversation.append({
                "role": "user",
                "parts": [question]
            })
            conversation.append({
                "role": "model",
                "parts": [response.text]
            })
            
            # 创建新的对话模型
            chat = model.start_chat(history=conversation)
            response = chat.send_message(question)
        
        print(f"问题 {i+1}: {question}")
        print(f"回答: {response.text}\n")
    
    return response.text

# 使用示例
questions = [
    "这张图片里有什么？",
    "图片中的主要颜色是什么？",
    "这张图片给你什么感觉？"
]

result = multi_turn_analysis('landscape.jpg', questions)
```

### 3. 自定义生成配置

```python
def analyze_with_config(image_path, prompt, temperature=0.7, max_tokens=2048):
    """使用自定义配置分析图像"""
    generation_config = {
        'temperature': temperature,      # 创造性：0.0-1.0
        'top_k': 40,                   # 词汇选择范围
        'top_p': 0.95,                 # 核采样
        'max_output_tokens': max_tokens # 最大输出长度
    }
    
    response = model.generate_content(
        [prompt, image_path],
        generation_config=generation_config
    )
    
    return response.text

# 使用示例
# 创造性回答
creative_result = analyze_with_config(
    'artwork.jpg',
    '请用富有诗意的语言描述这张图片',
    temperature=0.9,
    max_tokens=1000
)

# 客观描述
objective_result = analyze_with_config(
    'artwork.jpg',
    '请客观描述这张图片的技术细节',
    temperature=0.1,
    max_tokens=500
)
```

## ❓ 常见问题

### Q1: API 调用失败怎么办？

**A**: 检查以下几点：
- API 密钥是否正确
- 网络连接是否正常
- 图像格式是否支持
- 图像大小是否超限

### Q2: 如何处理大图像？

**A**: 使用图像预处理：
```python
def resize_image(image_path, max_size=1024):
    with Image.open(image_path) as img:
        if max(img.size) > max_size:
            img.thumbnail((max_size, max_size))
            img.save(image_path, 'JPEG', quality=85)
```

### Q3: 如何提高分析质量？

**A**: 
- 使用清晰的提示词
- 调整生成参数
- 进行多轮对话
- 结合图像预处理

### Q4: 支持哪些编程语言？

**A**: 官方支持：
- Python
- JavaScript/Node.js
- REST API（支持所有语言）

## 🎯 下一步

### 1. 深入学习

- 阅读 [API 参考文档](https://ai.google.dev/api/generative-ai)
- 查看 [最佳实践指南](https://ai.google.dev/docs/best_practices)
- 参与 [开发者社区](https://developers.google.com/community/ai)

### 2. 实践项目

- 创建图像描述生成器
- 构建视觉问答系统
- 开发图像分类工具
- 制作创意写作助手

### 3. 贡献社区

- 分享你的使用经验
- 提交代码示例
- 报告问题和建议
- 帮助其他开发者

---

**🎉 恭喜！你已经完成了快速入门教程。现在可以开始使用 Gemini 2.5 Flash Image Preview 创建有趣的应用了！**

如果遇到问题，请查看 [常见问题](#常见问题) 部分或访问我们的 [GitHub 讨论区](https://github.com/your-repo/discussions)。
