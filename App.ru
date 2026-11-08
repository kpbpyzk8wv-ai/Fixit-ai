from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    data = request.form.to_dict()
    image_url = data.get('image_url')
    description = data.get('description', 'Что сломалось?')

    if not image_url:
        return jsonify({"error": "Нет ссылки на изображение"}), 400

    POLZA_API_KEY = os.environ.get("POLZA_API_KEY", "ВСТАВЬ_СЮДА_КЛЮЧ_ПОЗЖЕ")
    
    payload = {
        "model": "qwen/qwen3.6-plus",
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": f"Ты мастер по ремонту. Клиент прислал фото с описанием: {description}. Определи тип поломки и назови примерную стоимость ремонта в рублях."},
                    {"type": "image_url", "image_url": {"url": image_url}}
                ]
            }
        ]
    }
    headers = {
        "Authorization": f"Bearer {POLZA_API_KEY}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post("https://polza.ai/api/v1/chat/completions", json=payload, headers=headers, timeout=30)
        result = response.json()
        answer = result['choices'][0]['message']['content']
        return jsonify({"diagnosis": answer}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000)
