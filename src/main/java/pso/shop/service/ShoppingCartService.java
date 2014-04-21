package pso.shop.service;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import pso.shop.domain.OrderProduct;
import pso.shop.domain.ShoppingCart;


/**
 * Stateful service tied to session scope to facade the details of a shopping cart
 * Note: This is a deliberate use of sessions to demonstrate a scenario where details are 
 * maintained in a session. 
 *
 * @author Biju Kunjummen
 */
@Service
public class ShoppingCartService {
	
	//Autowiring in httpsession
	@Autowired
	private HttpSession httpSession;
	
	private static final String CART_ATTRIBUTE_NAME="shoppingcart";
	
	private ShoppingCart getShoppingCartInSession() {
		ShoppingCart shoppingCart = (ShoppingCart)this.httpSession.getAttribute(CART_ATTRIBUTE_NAME);
		if (shoppingCart == null) {
			shoppingCart = new ShoppingCart();
			this.httpSession.setAttribute(CART_ATTRIBUTE_NAME, shoppingCart);
		}
		return shoppingCart;
	}
	
	
	public void addToCart(OrderProduct orderProduct) {
		ShoppingCart shoppingCart = getShoppingCartInSession();
		shoppingCart.addToCart(orderProduct);
	}
	
	public void removeFromCart(long productId) {
		ShoppingCart shoppingCart = getShoppingCartInSession();
		shoppingCart.removeItemFromCart(productId);
	}
	
	public void updateCart(List<OrderProduct> orderProducts) {
		ShoppingCart shoppingCart = getShoppingCartInSession();
		shoppingCart.updateCart(orderProducts);
	}
	public List<OrderProduct> getProductsInCart() {
		ShoppingCart shoppingCart = getShoppingCartInSession();
		return shoppingCart.getProductsInCart();
	}
}