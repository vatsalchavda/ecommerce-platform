package com.ecommerce.product.service;

import com.ecommerce.product.event.EventType;
import com.ecommerce.product.event.ProductEvent;
import com.ecommerce.product.exception.ProductNotFoundException;
import com.ecommerce.product.messaging.KafkaProductProducer;
import com.ecommerce.product.model.Product;
import com.ecommerce.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductService {

    private final ProductRepository productRepository;
    private final KafkaProductProducer kafkaProductProducer;

    public List<Product> getAllProducts() {
        log.info("Fetching all products");
        return productRepository.findAll();
    }

    public Product getProductById(String id) {
        log.info("Fetching product with id: {}", id);
        return productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException(id));
    }

    public List<Product> getProductsByCategory(String category) {
        log.info("Fetching products in category: {}", category);
        return productRepository.findByCategory(category);
    }

    public Product createProduct(Product product){
        log.info("Creating a new product: {}", product.getName());
        product.setCreatedAt(LocalDateTime.now());
        product.setUpdatedAt(LocalDateTime.now());
        Product savedProduct = productRepository.save(product);

        // Publish product created event
        ProductEvent event = new ProductEvent(
            savedProduct.getId(),
            savedProduct.getName(),
            savedProduct.getDescription(),
            savedProduct.getPrice(),
            savedProduct.getCategory(),
            savedProduct.getStockQuantity(),
            EventType.CREATED
        );
        kafkaProductProducer.sendProductEvent(event);

        log.info("Product created successfully with ID: {}", savedProduct.getId());
        return savedProduct;
    }

    public Product updateProduct(String id, Product productDetails){
        log.info("Updating product with id: {}", id);
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException(id));

        product.setName(productDetails.getName());
        product.setDescription(productDetails.getDescription());
        product.setPrice(productDetails.getPrice());
        product.setCategory(productDetails.getCategory());
        product.setStockQuantity(productDetails.getStockQuantity());
        product.setUpdatedAt(LocalDateTime.now());

        Product updatedProduct = productRepository.save(product);

        // Publish product updated event
        ProductEvent event = new ProductEvent(
            updatedProduct.getId(),
            updatedProduct.getName(),
            updatedProduct.getDescription(),
            updatedProduct.getPrice(),
            updatedProduct.getCategory(),
            updatedProduct.getStockQuantity(),
            EventType.UPDATED
        );
        kafkaProductProducer.sendProductEvent(event);

        log.info("Product updated successfully: {}", id);
        return updatedProduct;
    }

    public void deleteProduct(String id) {
        log.info("Deleting product with id: {}", id);
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException(id));

        // Publish product deleted event (before actual deletion)
        ProductEvent event = new ProductEvent(
            product.getId(),
            product.getName(),
            product.getDescription(),
            product.getPrice(),
            product.getCategory(),
            product.getStockQuantity(),
            EventType.DELETED
        );
        kafkaProductProducer.sendProductEvent(event);

        productRepository.delete(product);
        log.info("Product deleted successfully: {}", id);
    }
}