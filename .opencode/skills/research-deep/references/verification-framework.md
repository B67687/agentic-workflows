# Verification Framework

For every significant claim:

1. **Triangulate**: Find 2+ independent sources confirming the same fact
   - Independent means different authors, different organizations, different publication dates
   - Two blog posts quoting the same source = NOT independent

2. **Check provenance**: Who said this? What's their expertise?
   - Are they the creator of the thing being discussed?
   - Do they have a track record of accuracy?
   - Are they selling something related?

3. **Check recency**: Is this information still current?
   - Software docs: check version/date
   - Benchmarks: check if newer results exist
   - APIs: check if endpoints are deprecated

4. **Flag uncertainty**: If only one source exists, mark as tentative
   - Use "Likely" or "Speculative" confidence labels
   - Never present single-source claims as confirmed facts

## Red Flags
- No author attribution
- Circular references (A cites B, B cites A)
- Outdated screenshots or version numbers
- Claims that contradict official documentation
