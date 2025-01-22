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
<img alt="Flutter" src ="https://img.shields.io/badge/Flutter-02569B.svg?&style=for-the-badge&logo=Flutter&logoColor=white"/>

### Backend
- **Python**: Server-side logic implementation
- **AWS**: Cloud infrastructure and service hosting
- **OpenAI**: AI-powered paper analysis and summarization
- **FastAPI**: High-performance API development
- <img alt="Python" src ="https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54"/><img alt="AWS" src ="https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white"/><img alt="Openai" src ="https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=OpenAI&logoColor=white"/> 

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


## Contact

Project Maintainer - [@minhjih](https://instagram.com/minhjih) - jhchoi0226@snu.ac.kr

Project Link: [https://github.com/minhjih/dailyexp](https://github.com/minhjih/dailyexp)

# Api Endpoint
[API endpoint](/backend/app/docs/api_endpoints.md)
