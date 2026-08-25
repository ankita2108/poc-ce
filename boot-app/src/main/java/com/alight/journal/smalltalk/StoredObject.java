package com.alight.journal.smalltalk;

import java.util.Objects;
import java.util.UUID;

public class StoredObject extends SmalltalkObject {

    private String storageKey;
    private String status = "new";

    public StoredObject() {
        this.storageKey = UUID.randomUUID().toString();
    }

    public String getStorageKey() {
        return storageKey;
    }

    public void setStorageKey(String storageKey) {
        this.storageKey = storageKey;
    }

    public String getStatus() {
        return status;
    }

    public boolean isNew() {
        return "new".equals(status);
    }

    public boolean isDirty() {
        return "dirty".equals(status);
    }

    public boolean isClean() {
        return "clean".equals(status);
    }

    public void makeNew() {
        this.status = "new";
    }

    public void makeDirty() {
        this.status = "dirty";
    }

    public void makeClean() {
        this.status = "clean";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        StoredObject that = (StoredObject) o;
        return Objects.equals(storageKey, that.storageKey);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(storageKey);
    }

    public StoredObject clone() {
        try {
            return (StoredObject) super.clone();
        } catch (CloneNotSupportedException e) {
            StoredObject copy = new StoredObject();
            copy.storageKey = this.storageKey;
            copy.status = this.status;
            return copy;
        }
    }
}
