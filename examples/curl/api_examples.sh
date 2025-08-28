#!/bin/bash

# Gemini 2.5 Flash Image Preview cURL 使用示例
# 这个脚本展示了如何使用 cURL 命令行工具调用 Gemini API

# 设置变量
API_KEY="your-api-key-here"  # 请替换为你的实际 API 密钥
MODEL="gemini-2.5-flash-image-preview"
BASE_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent"

# 颜色输出函数
print_success() {
    echo -e "\033[32m✅ $1\033[0m"
}

print_error() {
    echo -e "\033[31m❌ $1\033[0m"
}

print_info() {
    echo -e "\033[34mℹ️  $1\033[0m"
}

print_warning() {
    echo -e "\033[33m⚠️  $1\033[0m"
}

# 检查 API 密钥是否设置
check_api_key() {
    if [ "$API_KEY" = "your-api-key-here" ]; then
        print_error "请先设置 API_KEY 变量"
        echo "使用方法: export API_KEY='your-actual-api-key'"
        exit 1
    fi
}

# 示例 1: 基础文本生成（不包含图像）
basic_text_generation() {
    print_info "示例 1: 基础文本生成"
    
    curl -X POST "${BASE_URL}?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "contents": [{
                "parts": [{
                    "text": "请介绍一下 Gemini 2.5 Flash Image Preview 模型的特点"
                }]
            }],
            "generationConfig": {
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            }
        }' | jq '.candidates[0].content.parts[0].text' 2>/dev/null || echo "请安装 jq 工具以获得更好的输出格式"
}

# 示例 2: 图像分析（使用 Base64 编码的图像）
image_analysis_base64() {
    print_info "示例 2: 图像分析（Base64 编码）"
    
    # 注意：这里使用一个示例 Base64 字符串，实际使用时需要替换为真实的图像数据
    # 可以使用以下命令将图像转换为 Base64：
    # base64 -i your_image.jpg
    
    curl -X POST "${BASE_URL}?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "contents": [{
                "parts": [
                    {
                        "text": "请详细描述这张图片中的内容"
                    },
                    {
                        "inline_data": {
                            "mime_type": "image/jpeg",
                            "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
                        }
                    }
                ]
            }],
            "generationConfig": {
                "temperature": 0.4,
                "topK": 32,
                "topP": 1,
                "maxOutputTokens": 2048
            }
        }' | jq '.candidates[0].content.parts[0].text' 2>/dev/null || echo "请安装 jq 工具以获得更好的输出格式"
}

# 示例 3: 图像分析（从文件读取）
image_analysis_file() {
    print_info "示例 3: 图像分析（从文件读取）"
    
    if [ ! -f "sample_image.jpg" ]; then
        print_warning "示例图像文件不存在，跳过此示例"
        echo "请将图像文件命名为 sample_image.jpg 并放在当前目录"
        return
    fi
    
    # 将图像转换为 Base64
    IMAGE_BASE64=$(base64 -i sample_image.jpg)
    
    curl -X POST "${BASE_URL}?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"contents\": [{
                \"parts\": [
                    {
                        \"text\": \"请分析这张图片，包括物体、场景、颜色和情感\"
                    },
                    {
                        \"inline_data\": {
                            \"mime_type\": \"image/jpeg\",
                            \"data\": \"${IMAGE_BASE64}\"
                        }
                    }
                ]
            }],
            \"generationConfig\": {
                \"temperature\": 0.3,
                \"topK\": 32,
                \"topP\": 1,
                \"maxOutputTokens\": 2048
            }
        }" | jq '.candidates[0].content.parts[0].text' 2>/dev/null || echo "请安装 jq 工具以获得更好的输出格式"
}

# 示例 4: 多轮对话
multi_turn_conversation() {
    print_info "示例 4: 多轮对话"
    
    # 第一轮对话
    print_info "第一轮：询问图像内容"
    RESPONSE1=$(curl -s -X POST "${BASE_URL}?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "contents": [{
                "parts": [
                    {
                        "text": "这张图片里有什么？"
                    },
                    {
                        "inline_data": {
                            "mime_type": "image/jpeg",
                            "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
                        }
                    }
                ]
            }]
        }')
    
    # 提取第一轮的回答
    FIRST_RESPONSE=$(echo "$RESPONSE1" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || echo "无法解析响应")
    
    print_info "第一轮回答: $FIRST_RESPONSE"
    
    # 第二轮对话（基于第一轮的回答）
    print_info "第二轮：基于第一轮回答的追问"
    curl -X POST "${BASE_URL}?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"contents\": [
                {
                    \"parts\": [
                        {
                            \"text\": \"这张图片里有什么？\"
                        },
                        {
                            \"inline_data\": {
                                \"mime_type\": \"image/jpeg\",
                                \"data\": \"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==\"
                            }
                        }
                    ]
                },
                {
                    \"parts\": [{
                        \"text\": \"$FIRST_RESPONSE\"
                    }]
                },
                {
                    \"parts\": [{
                        \"text\": \"请基于刚才的描述，进一步分析这张图片的细节\"
                    }]
                }
            ]
        }" | jq '.candidates[0].content.parts[0].text' 2>/dev/null || echo "请安装 jq 工具以获得更好的输出格式"
}

# 示例 5: 批量处理（模拟）
batch_processing() {
    print_info "示例 5: 批量处理（模拟）"
    
    # 这里展示如何批量处理多个图像
    # 实际使用时，你需要循环处理多个图像文件
    
    echo "批量处理示例："
    echo "1. 遍历图像目录"
    echo "2. 将每个图像转换为 Base64"
    echo "3. 调用 API 进行分析"
    echo "4. 保存结果到文件"
    
    # 示例脚本结构
    cat << 'EOF'
#!/bin/bash
# 批量处理脚本示例

for image in images/*.{jpg,jpeg,png}; do
    if [ -f "$image" ]; then
        echo "处理图像: $image"
        base64_image=$(base64 -i "$image")
        
        # 调用 API
        response=$(curl -s -X POST "${BASE_URL}?key=${API_KEY}" \
            -H "Content-Type: application/json" \
            -d "{
                \"contents\": [{
                    \"parts\": [
                        {\"text\": \"请描述这张图片\"},
                        {\"inline_data\": {\"mime_type\": \"image/jpeg\", \"data\": \"$base64_image\"}}
                    ]
                }]
            }")
        
        # 保存结果
        filename=$(basename "$image")
        echo "$response" > "results/${filename%.*}.json"
        echo "✅ 完成: $image"
    fi
done
EOF
}

# 示例 6: 错误处理
error_handling() {
    print_info "示例 6: 错误处理"
    
    # 测试无效的 API 密钥
    print_info "测试无效 API 密钥："
    curl -s -X POST "${BASE_URL}?key=invalid-key" \
        -H "Content-Type: application/json" \
        -d '{
            "contents": [{
                "parts": [{
                    "text": "测试"
                }]
            }]
        }' | jq '.error.message' 2>/dev/null || echo "请安装 jq 工具以获得更好的输出格式"
    
    echo ""
    
    # 测试无效的请求格式
    print_info "测试无效请求格式："
    curl -s -X POST "${BASE_URL}?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "invalid": "format"
        }' | jq '.error.message' 2>/dev/null || echo "请安装 jq 工具以获得更好的输出格式"
}

# 示例 7: 性能测试
performance_test() {
    print_info "示例 7: 性能测试"
    
    echo "开始性能测试..."
    start_time=$(date +%s.%N)
    
    # 执行多次 API 调用
    for i in {1..3}; do
        echo "测试 $i/3..."
        curl -s -X POST "${BASE_URL}?key=${API_KEY}" \
            -H "Content-Type: application/json" \
            -d '{
                "contents": [{
                    "parts": [{
                        "text": "请简单介绍一下你自己"
                    }]
                }]
            }' > /dev/null
        
        # 添加延迟避免速率限制
        sleep 1
    done
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "无法计算时间")
    
    print_success "性能测试完成，总耗时: ${duration} 秒"
}

# 主菜单
show_menu() {
    echo ""
    echo "🚀 Gemini 2.5 Flash Image Preview cURL 示例"
    echo "=========================================="
    echo "1. 基础文本生成"
    echo "2. 图像分析（Base64）"
    echo "3. 图像分析（文件）"
    echo "4. 多轮对话"
    echo "5. 批量处理示例"
    echo "6. 错误处理"
    echo "7. 性能测试"
    echo "8. 运行所有示例"
    echo "0. 退出"
    echo ""
    read -p "请选择示例 (0-8): " choice
}

# 运行所有示例
run_all_examples() {
    print_info "运行所有示例..."
    basic_text_generation
    echo ""
    image_analysis_base64
    echo ""
    image_analysis_file
    echo ""
    multi_turn_conversation
    echo ""
    batch_processing
    echo ""
    error_handling
    echo ""
    performance_test
}

# 主程序
main() {
    check_api_key
    
    while true; do
        show_menu
        
        case $choice in
            1) basic_text_generation ;;
            2) image_analysis_base64 ;;
            3) image_analysis_file ;;
            4) multi_turn_conversation ;;
            5) batch_processing ;;
            6) error_handling ;;
            7) performance_test ;;
            8) run_all_examples ;;
            0) print_info "再见！"; exit 0 ;;
            *) print_error "无效选择，请重试" ;;
        esac
        
        echo ""
        read -p "按回车键继续..."
    done
}

# 如果直接运行脚本，显示菜单；如果作为函数调用，不显示菜单
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
