import openai
from typing import Dict, List, Optional
import os
from dotenv import load_dotenv

load_dotenv()

class GPTService:
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")
        openai.api_key = self.api_key

    async def analyze_paper(self, paper_data: Dict) -> Dict:
        """
        논문을 분석하여 구조화된 요약을 생성합니다.
        """
        # GPT-4에게 전달할 프롬프트 생성
        prompt = self._create_analysis_prompt(paper_data)
        
        try:
            response = await openai.ChatCompletion.acreate(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": """
                    당신은 학술 논문 분석 전문가입니다. 
                    논문의 각 섹션을 분석하고 다음 형식으로 구조화된 요약을 제공해주세요:
                    1. 핵심 주장
                    2. 각 섹션별 주요 내용
                    3. 연구 방법론
                    4. 주요 발견
                    5. 사용된 시각적 자료 목록 (표, 그림)
                    6. 향후 연구 방향
                    """},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=2000
            )
            
            return self._parse_gpt_response(response.choices[0].message.content)
        
        except Exception as e:
            raise Exception(f"GPT 분석 실패: {str(e)}")

    def _create_analysis_prompt(self, paper_data: Dict) -> str:
        """
        논문 데이터를 기반으로 GPT 프롬프트를 생성합니다.
        """
        return f"""
        제목: {paper_data['title']}
        초록: {paper_data['abstract']}
        
        이 논문을 분석하여 다음 사항들을 포함한 구조화된 요약을 제공해주세요:
        1. 논문의 핵심 주장과 의의
        2. 각 섹션별 주요 내용 요약
        3. 사용된 연구 방법론 설명
        4. 주요 발견 사항들
        5. 논문에 포함된 표와 그림들의 목록과 각각의 핵심 내용
        6. 저자들이 제시한 향후 연구 방향
        
        가능한 한 구체적이고 명확하게 분석해주세요.
        """

    def _parse_gpt_response(self, response: str) -> Dict:
        """
        GPT 응답을 구조화된 형식으로 파싱합니다.
        """
        # 여기서는 간단한 파싱을 가정합니다.
        # 실제 구현시에는 더 정교한 파싱 로직이 필요할 수 있습니다.
        sections = response.split('\n\n')
        
        analysis = {
            "core_claims": "",
            "section_summaries": {},
            "methodology": "",
            "key_findings": [],
            "visual_elements": [],
            "future_research": ""
        }
        
        current_section = ""
        for section in sections:
            if "핵심 주장" in section:
                analysis["core_claims"] = section
            elif "방법론" in section:
                analysis["methodology"] = section
            elif "주요 발견" in section:
                analysis["key_findings"] = section
            elif "시각적 자료" in section:
                analysis["visual_elements"] = section
            elif "향후 연구" in section:
                analysis["future_research"] = section
                
        return analysis 