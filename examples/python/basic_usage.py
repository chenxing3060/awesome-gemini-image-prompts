#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gemini 2.5 Flash Image Preview 基础使用示例

这个文件展示了如何使用 Gemini 2.5 Flash Image Preview 模型进行基本的图像分析。
"""

import os
import google.generativeai as genai
from PIL import Image
import base64
from io import BytesIO


def setup_api():
    """设置 Gemini API 配置"""
    # 从环境变量获取 API 密钥
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key:
        raise ValueError('请设置环境变量 GEMINI_API_KEY')
    
    genai.configure(api_key=api_key)
    print('✅ API 配置成功')


def create_model():
    """创建 Gemini 模型实例"""
    try:
        model = genai.GenerativeModel('gemini-2.5-flash-image-preview')
        print('✅ 模型创建成功')
        return model
    except Exception as e:
        print(f'❌ 模型创建失败: {e}')
        return None


def analyze_image_from_file(model, image_path, prompt):
    """
    从文件路径分析图像
    
    Args:
        model: Gemini 模型实例
        image_path: 图像文件路径
        prompt: 分析提示词
    
    Returns:
        str: 分析结果
    """
    try:
        # 检查文件是否存在
        if not os.path.exists(image_path):
            raise FileNotFoundError(f'图像文件不存在: {image_path}')
        
        # 生成内容
        response = model.generate_content([prompt, image_path])
        return response.text
    
    except Exception as e:
        print(f'❌ 图像分析失败: {e}')
        return None


def analyze_image_from_pil(model, image, prompt):
    """
    从 PIL Image 对象分析图像
    
    Args:
        model: Gemini 模型实例
        image: PIL Image 对象
        prompt: 分析提示词
    
    Returns:
        str: 分析结果
    """
    try:
        response = model.generate_content([prompt, image])
        return response.text
    
    except Exception as e:
        print(f'❌ 图像分析失败: {e}')
        return None


def analyze_image_from_base64(model, base64_string, prompt):
    """
    从 Base64 字符串分析图像
    
    Args:
        model: Gemini 模型实例
        base64_string: Base64 编码的图像字符串
        prompt: 分析提示词
    
    Returns:
        str: 分析结果
    """
    try:
        # 解码 Base64 字符串
        image_data = base64.b64decode(base64_string)
        image = Image.open(BytesIO(image_data))
        
        response = model.generate_content([prompt, image])
        return response.text
    
    except Exception as e:
        print(f'❌ 图像分析失败: {e}')
        return None


def batch_analyze_images(model, image_dir, prompt):
    """
    批量分析目录中的图像
    
    Args:
        model: Gemini 模型实例
        image_dir: 图像目录路径
        prompt: 分析提示词
    
    Returns:
        dict: 文件名到分析结果的映射
    """
    results = {}
    supported_formats = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'}
    
    try:
        for filename in os.listdir(image_dir):
            if any(filename.lower().endswith(fmt) for fmt in supported_formats):
                image_path = os.path.join(image_dir, filename)
                result = analyze_image_from_file(model, image_path, prompt)
                if result:
                    results[filename] = result
                    print(f'✅ 已分析: {filename}')
                else:
                    print(f'❌ 分析失败: {filename}')
        
        return results
    
    except Exception as e:
        print(f'❌ 批量分析失败: {e}')
        return {}


def main():
    """主函数 - 演示各种使用方法"""
    print('🚀 Gemini 2.5 Flash Image Preview 基础使用示例\n')
    
    # 设置 API
    try:
        setup_api()
    except ValueError as e:
        print(f'❌ {e}')
        return
    
    # 创建模型
    model = create_model()
    if not model:
        return
    
    # 示例 1: 从文件分析图像
    print('\n📸 示例 1: 从文件分析图像')
    image_path = 'sample_image.jpg'  # 请替换为实际的图像路径
    if os.path.exists(image_path):
        result = analyze_image_from_file(
            model, 
            image_path, 
            '请详细描述这张图片中的内容，包括物体、场景、颜色和情感'
        )
        if result:
            print(f'分析结果:\n{result}\n')
    else:
        print(f'⚠️  示例图像文件不存在: {image_path}')
    
    # 示例 2: 批量分析
    print('📸 示例 2: 批量分析图像')
    image_dir = 'images'  # 请替换为实际的图像目录
    if os.path.exists(image_dir):
        results = batch_analyze_images(
            model,
            image_dir,
            '请简要描述这张图片的主要内容'
        )
        print(f'批量分析完成，共处理 {len(results)} 张图像\n')
    else:
        print(f'⚠️  示例图像目录不存在: {image_dir}')
    
    print('🎉 示例运行完成！')


if __name__ == '__main__':
    main()
