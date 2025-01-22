# DailyExp

DailyExp is an innovative research tracking and knowledge sharing platform designed for graduate students. It offers a comprehensive solution for receiving recommendations on the latest papers in your field of interest, capturing key insights, sharing them with your research group, and publicly posting your paper reviews to spread knowledge.

## Key Features

- **Personalized Paper Recommendations**: Get daily recommendations for papers from top journals in your area of interest.
- **Intuitive Summaries**: Receive concise summaries and key intuitions from recommended papers.
- **Scrap and Share**: Easily scrap important sections and instantly share them with your research group.
- **Public Review Posting**: Post your paper reviews publicly to disseminate knowledge.
- **Follow System**: Follow other researchers to gain insights from their work and reviews.
- **Integrated Workspace**: A unified workspace for individual and group research activities.

## Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile application development

### Backend
- **Python**: Server-side logic implementation
- **AWS**: Cloud infrastructure and service hosting
- **OpenAI**: AI-powered paper analysis and summarization
- **FastAPI**: High-performance API development

## Installation

```bash
# Clone the repository
git clone https://github.com/minhjih/dailyexp.git

# Navigate to the project directory
cd dailyexp

# Run the server
cd backend
pip install -r requirements.txt
uvicorn main:app --reload

# Run the Flutter app (in a separate terminal)
flutter pub get
flutter run
```

## Usage

1. Launch the app and create an account.
2. Set your research interests.
3. Browse recommended papers and read their summaries.
4. Scrap important sections and share them with your research group.
5. Write and publicly post your personal reviews of papers.
6. Follow other researchers and gain insights from their work.

## Contributing

To contribute to DailyExp:

1. Fork this repository.
2. Create a new feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## License

This project is distributed under the MIT License. See `LICENSE` file for more information.

## Contact

Project Maintainer - [@minhjih](https://instagram.com/minhjih) - jhchoi0226@snu.ac.kr

Project Link: [https://github.com/minhjih/dailyexp](https://github.com/minhjih/dailyexp)

# Api Endpoint
[API endpoint](/backend/app/docs/api_endpoints.md)
