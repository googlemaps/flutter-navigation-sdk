package com.google.maps.flutter.navigation

import com.google.android.libraries.navigation.NavigationApi
import com.google.android.libraries.navigation.Navigator

/**
 * Singleton holder for the shared Navigator instance.
 * Multiple GoogleMapsNavigationSessionManager instances share the same Navigator.
 */
enum class GoogleNavigatorInitializationState {
    NOT_INITIALIZED,
    INITIALIZING,
    INITIALIZED,
}

object GoogleMapsNavigatorHolder {
    @Volatile
    private var navigator: Navigator? = null
    private var initializationState = GoogleNavigatorInitializationState.NOT_INITIALIZED
    private val initializationCallbacks = mutableListOf<NavigationApi.NavigatorListener>()

    @Synchronized
    fun getNavigator(): Navigator? = navigator

    @Synchronized
    fun setNavigator(nav: Navigator?) {
        navigator = nav
        initializationState = if (nav != null) {
            GoogleNavigatorInitializationState.INITIALIZED
        } else {
            GoogleNavigatorInitializationState.NOT_INITIALIZED
        }
    }

    @Synchronized
    fun getInitializationState(): GoogleNavigatorInitializationState = initializationState

    @Synchronized
    fun setInitializationState(state: GoogleNavigatorInitializationState) {
        initializationState = state
    }

    @Synchronized
    fun addInitializationCallback(callback: NavigationApi.NavigatorListener) {
        initializationCallbacks.add(callback)
    }

    @Synchronized
    fun getAndClearInitializationCallbacks(): List<NavigationApi.NavigatorListener> {
        val callbacks = initializationCallbacks.toList()
        initializationCallbacks.clear()
        return callbacks
    }

    @Synchronized
    fun reset() {
        navigator = null
        initializationState = GoogleNavigatorInitializationState.NOT_INITIALIZED
        initializationCallbacks.clear()
    }
}