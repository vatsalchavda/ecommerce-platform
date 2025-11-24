package com.ecommerce.product.messaging;

import com.ecommerce.product.event.ProductEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class KafkaProductConsumer {

    private static final Logger logger = LoggerFactory.getLogger(KafkaProductConsumer.class);

    @KafkaListener(topics = "product-events", groupId = "product-service-group")
    public void consumeProductEvent(ProductEvent event) {
        logger.info("Received product event: {} for product: {} (ID: {})",
                event.eventType(),
                event.name(),
                event.id());

        // In a real microservice architecture, this would be in a different service
        // For example:
        // - Order Service: Update product catalog cache
        // - Inventory Service: Initialize stock tracking
        // - Search Service: Update search index
        // - Analytics Service: Track product lifecycle

        logger.debug("Product event details: {}", event);
    }
}
