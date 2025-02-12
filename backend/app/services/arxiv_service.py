import arxiv

class ArxivService:
    async def search_papers(self, query: str, max_results: int = 10):
        search = arxiv.Search(
            query=query,
            max_results=max_results,
            sort_by=arxiv.SortCriterion.Relevance
        )
        
        papers = []
        for result in search.results():
            papers.append({
                'title': result.title,
                'authors': [author.name for author in result.authors],
                'summary': result.summary,
                'published_date': result.published.strftime('%Y-%m-%d'),
                'url': result.pdf_url,
                'arxiv_id': result.entry_id,
                'categories': result.categories
            })
        
        return papers 