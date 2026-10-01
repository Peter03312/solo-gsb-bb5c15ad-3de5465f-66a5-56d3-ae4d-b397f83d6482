FROM python:3.12-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 运行依赖在**镜像构建阶段**一次性备齐：pip 安装任一步失败（网络/版本/编译问题）
# 都会让该 RUN 层非零退出并直接中断 docker build，绝不会带病产出镜像；
# 末尾的导入自检在构建期再次确认关键依赖真实可用。
# 容器启动时不再访问网络、不再执行 pip，冷启动直接拉起 API。
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt \
    && python -c "import fastapi, uvicorn, pydantic, ortools" \
    && echo "[build] runtime dependencies installed and importable"

COPY app /app/app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh && mkdir -p /data

EXPOSE 8000
ENTRYPOINT ["/app/entrypoint.sh"]
