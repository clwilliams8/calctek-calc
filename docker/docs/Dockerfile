FROM squidfunk/mkdocs-material:latest

COPY docs/ /docs/

RUN pip install --no-cache-dir -r /docs/requirements.txt 2>/dev/null || true

RUN mkdocs build

EXPOSE 8000

ENTRYPOINT []
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]
