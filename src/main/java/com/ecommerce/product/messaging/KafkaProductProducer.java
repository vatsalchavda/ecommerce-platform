package com.ecommerce.product.messaging;

import com.ecommerce.product.event.ProductEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class KafkaProductProducer {

    private static final Logger logger = LoggerFactory.getLogger(KafkaProductProducer.class);
    private static final String TOPIC = "product-events";

    private final KafkaTemplate<String, ProductEvent> kafkaTemplate;

    public KafkaProductProducer(KafkaTemplate<String, ProductEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendProductEvent(ProductEvent event) {
        logger.info("Publishing product event: {} for product ID: {}", event.eventType(), event.id());

        kafkaTemplate.send(TOPIC, event.id(), event)
                .whenComplete((result, ex) -> {
                    if (ex == null) {
                        logger.info("Product event published successfully: {} - Partition: {}, Offset: {}",
                                event.id(),
                                result.getRecordMetadata().partition(),
                                result.getRecordMetadata().offset());
                    } else {
                        logger.error("Failed to publish product event: {}", event.id(), ex);
                    }
                });
    }
}
