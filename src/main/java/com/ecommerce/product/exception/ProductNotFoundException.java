package com.ecommerce.product.exception;

public class ProductNotFoundException extends RuntimeException {

    public ProductNotFoundException(String id) {
        super("Product not found with id: " + id);
    }

    public ProductNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}
