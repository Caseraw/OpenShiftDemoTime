from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from . import db

app = FastAPI(title="Mini Contacts API")

class ContactIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    email: EmailStr
    note: Optional[str] = Field(default=None, max_length=1000)

class ContactOut(ContactIn):
    id: int

@app.get("/healthz")
def healthz():
    row = db.fetch_one("SELECT 1;")
    return {"ok": row is not None}

@app.get("/contacts", response_model=List[ContactOut])
def list_contacts(q: Optional[str] = None, limit: int = 50, offset: int = 0):
    if q:
        rows = db.fetch_all(
            "SELECT id, name, email, note FROM contacts WHERE name ILIKE %s OR email ILIKE %s "
            "ORDER BY id DESC LIMIT %s OFFSET %s",
            (f"%{q}%", f"%{q}%", limit, offset),
        )
    else:
        rows = db.fetch_all(
            "SELECT id, name, email, note FROM contacts ORDER BY id DESC LIMIT %s OFFSET %s",
            (limit, offset),
        )
    return [dict(id=r[0], name=r[1], email=r[2], note=r[3]) for r in rows]

@app.post("/contacts", response_model=ContactOut, status_code=201)
def create_contact(c: ContactIn):
    try:
        db.execute(
            "INSERT INTO contacts (name, email, note) VALUES (%s, %s, %s);",
            (c.name, c.email, c.note),
        )
    except Exception as ex:
        # e.g., duplicate email unique constraint
        raise HTTPException(status_code=400, detail=str(ex))
    row = db.fetch_one(
        "SELECT id, name, email, note FROM contacts WHERE email=%s;",
        (c.email,),
    )
    return dict(id=row[0], name=row[1], email=row[2], note=row[3])

@app.patch("/contacts/{contact_id}", response_model=ContactOut)
def update_contact(contact_id: int, c: ContactIn):
    changed = db.execute(
        "UPDATE contacts SET name=%s, email=%s, note=%s WHERE id=%s;",
        (c.name, c.email, c.note, contact_id),
    )
    if changed == 0:
        raise HTTPException(status_code=404, detail="Not found")
    row = db.fetch_one(
        "SELECT id, name, email, note FROM contacts WHERE id=%s;",
        (contact_id,),
    )
    return dict(id=row[0], name=row[1], email=row[2], note=row[3])

@app.delete("/contacts/{contact_id}", status_code=204)
def delete_contact(contact_id: int):
    changed = db.execute("DELETE FROM contacts WHERE id=%s;", (contact_id,))
    if changed == 0:
        raise HTTPException(status_code=404, detail="Not found")
