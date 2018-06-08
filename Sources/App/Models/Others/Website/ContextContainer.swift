import Vapor

/// Контейнер для отображаемых данных на веб-странице
struct ContextContainer<T>: Context where T: Context {
    
    // MARK: - Публичные свойства
    
    /// Название страницы
    let title: String
    /// Индекс активного элемента меню
    let menuActiveItemIndex: Int?
    /// Отображать информацию об использовании cookie
    let showCookieMessage: Bool
    /// Данные
    let data: T?
    
    
    // MARK: - Инициализация
    
    init(title: String, menuActiveItemIndex: Int? = nil, data: T?, on request: Request) {
        self.title = title
        self.menuActiveItemIndex = menuActiveItemIndex
        self.data = data
        
        let showCookieMessage = request.http.cookies["cookies-accepted"] == nil
        self.showCookieMessage = showCookieMessage
    }
    
}
