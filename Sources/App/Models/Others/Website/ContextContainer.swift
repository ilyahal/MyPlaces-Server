import Vapor

/// Контейнер для отображаемых данных на веб-странице
struct ContextContainer<T>: Context where T: Context {
    
    // MARK: - Публичные свойства
    
    /// Название страницы
    let title: String
    /// Индекс активного элемента меню
    let navActiveItemIndex: Int?
    /// Отображать информацию об использовании cookie
    let showCookieMessage: Bool
    /// Данные
    let data: T?
    
    
    // MARK: - Инициализация
    
    init(title: String, navActiveItemIndex: Int? = nil, data: T?, on request: Request) {
        self.title = title
        self.navActiveItemIndex = navActiveItemIndex
        self.data = data
        
        let showCookieMessage = request.http.cookies["cookies-accepted"] == nil
        self.showCookieMessage = showCookieMessage
    }
    
}