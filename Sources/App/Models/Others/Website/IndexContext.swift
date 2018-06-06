
/// Данные для отображения на главной странице
struct IndexContext: Context {
    
    // MARK: - Публичные свойства
    
    let title: String
    /// Индекс активного элемента меню
    let navActiveItemIndex: Int
    /// Списки
    let lists: [List]
    
}
