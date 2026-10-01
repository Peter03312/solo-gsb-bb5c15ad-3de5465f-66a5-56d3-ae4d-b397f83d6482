#!/bin/sh
# 容器启动链（运行依赖已在镜像构建阶段安装，见 Dockerfile）：
#   1) 直接启动 API，不做任何 pip 安装、不访问外网，保证冷启动秒级就绪；
#   2) SQLite 建库/轻量迁移由 FastAPI lifespan 中的 database.init_db() 完成
#      （CREATE TABLE IF NOT EXISTS + 旧库补列，全新库与保留数据卷均幂等）；
#   3) 持久卷中遗留的未决任务（pending 及心跳陈旧的 running）由 lifespan 中的
#      startup_recover() 立即接管，之后守护线程周期重扫，无需人工干预。
set -e

echo "[entrypoint] starting API on 0.0.0.0:8000 ..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
