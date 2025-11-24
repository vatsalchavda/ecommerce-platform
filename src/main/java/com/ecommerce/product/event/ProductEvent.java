package com.ecommerce.product.event;

import java.math.BigDecimal;

public record ProductEvent(
        String id,
        String name,
        String description,
        BigDecimal price,
        String category,
        Integer stockQuantity,
        EventType eventType  // "CREATED", "UPDATED", "DELETED"
) { }