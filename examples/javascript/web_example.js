/**
 * Gemini 2.5 Flash Image Preview Web 前端使用示例
 * 
 * 这个文件展示了如何在浏览器中使用 Gemini 2.5 Flash Image Preview 模型
 */

class GeminiImageAnalyzer {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent';
    }

    /**
     * 将图像文件转换为 Base64 字符串
     * @param {File} file - 图像文件
     * @returns {Promise<string>} Base64 编码的字符串
     */
    async imageToBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    /**
     * 分析图像内容
     * @param {File|string} image - 图像文件或 Base64 字符串
     * @param {string} prompt - 分析提示词
     * @returns {Promise<Object>} API 响应结果
     */
    async analyzeImage(image, prompt) {
        try {
            let base64Image;
            
            if (image instanceof File) {
                base64Image = await this.imageToBase64(image);
            } else if (typeof image === 'string') {
                base64Image = image;
            } else {
                throw new Error('不支持的图像格式');
            }

            const requestBody = {
                contents: [{
                    parts: [
                        { text: prompt },
                        {
                            inline_data: {
                                mime_type: 'image/jpeg',
                                data: base64Image
                            }
                        }
                    ]
                }],
                generationConfig: {
                    temperature: 0.4,
                    topK: 32,
                    topP: 1,
                    maxOutputTokens: 2048,
                }
            };

            const response = await fetch(`${this.baseUrl}?key=${this.apiKey}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestBody)
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            return result;

        } catch (error) {
            console.error('图像分析失败:', error);
            throw error;
        }
    }

    /**
     * 批量分析多个图像
     * @param {Array<File>} images - 图像文件数组
     * @param {string} prompt - 分析提示词
     * @returns {Promise<Array>} 分析结果数组
     */
    async batchAnalyzeImages(images, prompt) {
        const results = [];
        
        for (let i = 0; i < images.length; i++) {
            try {
                console.log(`正在分析第 ${i + 1}/${images.length} 张图像...`);
                const result = await this.analyzeImage(images[i], prompt);
                results.push({
                    filename: images[i].name,
                    success: true,
                    result: result
                });
            } catch (error) {
                results.push({
                    filename: images[i].name,
                    success: false,
                    error: error.message
                });
            }
        }
        
        return results;
    }
}

// 使用示例
class ImageAnalysisDemo {
    constructor() {
        this.analyzer = null;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupUI();
    }

    setupEventListeners() {
        // 文件选择事件
        document.getElementById('imageInput').addEventListener('change', (e) => {
            this.handleFileSelection(e.target.files);
        });

        // 分析按钮事件
        document.getElementById('analyzeBtn').addEventListener('change', () => {
            this.analyzeSelectedImages();
        });

        // 批量分析按钮事件
        document.getElementById('batchAnalyzeBtn').addEventListener('change', () => {
            this.batchAnalyzeImages();
        });
    }

    setupUI() {
        // 创建 API 密钥输入框
        const apiKeyInput = document.createElement('input');
        apiKeyInput.type = 'password';
        apiKeyInput.placeholder = '请输入 Gemini API 密钥';
        apiKeyInput.id = 'apiKeyInput';
        apiKeyInput.style.width = '100%';
        apiKeyInput.style.padding = '8px';
        apiKeyInput.style.marginBottom = '10px';
        
        document.getElementById('controls').prepend(apiKeyInput);
    }

    handleFileSelection(files) {
        const previewContainer = document.getElementById('imagePreview');
        previewContainer.innerHTML = '';
        
        Array.from(files).forEach((file, index) => {
            if (file.type.startsWith('image/')) {
                const preview = document.createElement('div');
                preview.className = 'image-preview';
                preview.innerHTML = `
                    <img src="${URL.createObjectURL(file)}" alt="${file.name}" style="max-width: 150px; max-height: 150px;">
                    <p>${file.name}</p>
                `;
                previewContainer.appendChild(preview);
            }
        });
    }

    async analyzeSelectedImages() {
        const apiKey = document.getElementById('apiKeyInput').value.trim();
        if (!apiKey) {
            alert('请输入 API 密钥');
            return;
        }

        this.analyzer = new GeminiImageAnalyzer(apiKey);
        
        const files = document.getElementById('imageInput').files;
        if (files.length === 0) {
            alert('请选择图像文件');
            return;
        }

        const prompt = document.getElementById('promptInput').value.trim() || '请描述这张图片的内容';
        
        try {
            this.showLoading(true);
            
            if (files.length === 1) {
                const result = await this.analyzer.analyzeImage(files[0], prompt);
                this.displayResult(result, files[0].name);
            } else {
                const results = await this.analyzer.batchAnalyzeImages(files, prompt);
                this.displayBatchResults(results);
            }
        } catch (error) {
            this.showError(error.message);
        } finally {
            this.showLoading(false);
        }
    }

    displayResult(result, filename) {
        const resultContainer = document.getElementById('results');
        resultContainer.innerHTML = `
            <div class="result-item">
                <h3>分析结果: ${filename}</h3>
                <pre>${JSON.stringify(result, null, 2)}</pre>
            </div>
        `;
    }

    displayBatchResults(results) {
        const resultContainer = document.getElementById('results');
        let html = '<h3>批量分析结果</h3>';
        
        results.forEach(result => {
            html += `
                <div class="result-item ${result.success ? 'success' : 'error'}">
                    <h4>${result.filename}</h4>
                    ${result.success ? 
                        `<pre>${JSON.stringify(result.result, null, 2)}</pre>` :
                        `<p class="error">分析失败: ${result.error}</p>`
                    }
                </div>
            `;
        });
        
        resultContainer.innerHTML = html;
    }

    showLoading(show) {
        const loadingElement = document.getElementById('loading');
        if (loadingElement) {
            loadingElement.style.display = show ? 'block' : 'none';
        }
    }

    showError(message) {
        const resultContainer = document.getElementById('results');
        resultContainer.innerHTML = `<div class="error">错误: ${message}</div>`;
    }
}

// 页面加载完成后初始化演示
document.addEventListener('DOMContentLoaded', () => {
    new ImageAnalysisDemo();
});

// 导出类供其他模块使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { GeminiImageAnalyzer, ImageAnalysisDemo };
}
