FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && useradd --create-home --uid 10001 appuser \
    && mkdir -p /data \
    && chown -R 10001:10001 /data /app

COPY --chown=10001:10001 app/ /app/

USER 10001

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]