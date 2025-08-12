import os
from psycopg_pool import ConnectionPool

def _dsn():
    return (
        f"postgresql://{os.environ['POSTGRESQL_USER']}:"
        f"{os.environ['POSTGRESQL_PASSWORD']}@"
        f"{os.environ.get('POSTGRESQL_HOST','postgres')}:"
        f"{os.environ.get('POSTGRESQL_PORT','5432')}/"
        f"{os.environ['POSTGRESQL_DATABASE']}"
    )

pool = ConnectionPool(conninfo=_dsn(), min_size=1, max_size=4, timeout=10)

def fetch_all(sql, params=None):
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params or ())
            return cur.fetchall()

def fetch_one(sql, params=None):
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params or ())
            return cur.fetchone()

def execute(sql, params=None):
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params or ())
            conn.commit()
            return cur.rowcount
