package com.ecommerce.product.repository;

import com.ecommerce.product.model.Product;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends MongoRepository<Product, String> {

    // Custom query methods - Spring Data generates implementation automatically

    // Find products by category
    List<Product> findByCategory(String category);

    // Find product by name
    Optional<Product> findByName(String name);

    // Find products with stock greater than 0
    List<Product> findByStockQuantityGreaterThan(Integer quantity);
}