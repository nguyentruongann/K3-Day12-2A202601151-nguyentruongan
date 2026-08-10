# Thông Tin Deploy — Checkpoint 5

> Hoàn thiện các giá trị trong dấu `[...]` sau khi Railway deploy thành công.
> **Chỉ ghi tên/nguồn biến môi trường; tuyệt đối không ghi giá trị thật của `AGENT_API_KEY`.**

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | [Nguyễn Trường An] |
| Mã học viên | [2A202601151] |
| Repo | [https://github.com/nguyentruongann/K3-Day12-2A202601151-nguyentruongan.git] |

## Service

| Mục | Nội dung |
|-----|----------|
| Public URL | [https://day12-agent-production-38c9.up.railway.app] |
| Platform | Railway |
| Ngày deploy | 10/08/2026 |

## Biến Môi Trường Đã Set Trên Railway

| Biến | Đã set | Nguồn / ghi chú |
|------|--------|------------------|
| `PORT` | ✅ | Railway tự inject; không hardcode |
| `AGENT_API_KEY` | ✅ | Railway Variables; secret không nằm trong repo |
| `REDIS_URL` | ✅ | Reference variable: `${{Redis.REDIS_URL}}` |
| `RATE_LIMIT_PER_MINUTE` | ✅ | Railway Variables, giá trị cấu hình theo bài |
| `MONTHLY_BUDGET_USD` | ✅ | Railway Variables, giá trị cấu hình theo bài |
| `LOG_LEVEL` | ✅ | Railway Variables |

## Kiểm Tra Deployment

Thay `<URL>` bằng Public URL thật và `<API_KEY>` bằng secret đang lưu cục bộ của bạn.
Không commit API key vào repository.

```bash
# 1. Liveness — mong đợi HTTP 200 và status=ok
curl -i <URL>/health

# 2. Readiness — mong đợi HTTP 200 khi Redis kết nối thành công
curl -i <URL>/ready

# 3. Thiếu API key — mong đợi HTTP 401
curl -i -X POST <URL>/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"Hello"}'

# 4. Có API key — mong đợi HTTP 200
curl -i -X POST <URL>/ask \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <API_KEY>" \
  -H "X-User-Id: sv-test" \
  -d '{"question":"Deploy là gì?"}'
```

## Kết Quả Chạy Thật

```text
[PASTE_OUTPUT_HEALTH_READY_ASK_HERE]
```

## Ảnh Chụp Màn Hình

- `screenshots/dashboard.png` — Railway project có service app và Redis.
- `screenshots/health.png` — kết quả gọi Public URL `/health` trả HTTP 200.

## Ghi Chú Kiến Trúc

```text
Internet
   |
   v
Railway public domain
   |
   v
day12-agent (Dockerfile / FastAPI)
   |
   | REDIS_URL = ${{Redis.REDIS_URL}}
   v
Redis service (private network trong cùng Railway project)
```
