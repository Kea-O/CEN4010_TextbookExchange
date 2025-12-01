//
//  FeedView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import SwiftUI

// Create the main "feed" for the posts; here will be where users can scroll and search for textbooks or search for specific ones
struct FeedView: View {
    // Access the authManager from the environment
    @Environment(AuthManager.self) var authManager
    
    // A variable to store our current user. Can be filled outside of this file, such as with ContentView
    let user: AppUser
    
    // Create an instance of the in-between view model so we can call on it's functions. We're using the BetweenView instead of PostManager because BetweenView accounts for UI.
    @EnvironmentObject var betweenPost: PostBetweenView
    @Binding var selectedTab: AppTab?
    
    // We'll filter the posts so that users don't see their own posts in the feed.
    var filteredPosts: [Post] {
        betweenPost.posts.filter{$0.user_id != user.id}
    }
    
    // Now we'll filter the posts further with our search query:
    var searchPosts: [Post] {
        if searchText.isEmpty {
            return filteredPosts
        }

        return filteredPosts.filter { post in
            post.title.localizedCaseInsensitiveContains(searchText) ||
            post.author.localizedCaseInsensitiveContains(searchText) ||
            post.isbn.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // Create a variable to hold what the user is searching for:
    @State private var searchText = ""
    
    // The UI:
    var body: some View {
        // To keep the app looking sleek, the views are seperated via a Navigation Bar. We'll put this View under a NavigationStack so that we can link to the view from the ContentView.
        NavigationStack {
            // We'll make use of Group so we can use multiple Views with conditionals. This lets us streamline our code. In this case, we're checking for Posts to display. We'll display a Progress View while loading, a ContentUnavailableView if there are no posts, and finally a ScrollView when there are posts to scroll through them.
            // To check for posts we'll use the PostBetweenView instance, which also allows us to dynamically check and change the view based on if the data is loading in.
            Group {
                if betweenPost.isLoading && searchPosts.isEmpty {
                    ProgressView("Loading posts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchPosts.isEmpty {
                    ContentUnavailableView(
                        "No posts yet",
                        systemImage: "book.fill",
                        description: Text("New listings will appear here as soon as sellers post them.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        // Use LazyVStack to separate the posts and allow them to overflow instead of pushing up agaianst each other on one line. Also, LazyVStack only loads visible rows into memory, potentially saving a lot of energy.
                        LazyVStack(spacing: 16) {
                            // Loop through the posts and send them to a View defined below for proper UI. Furthermore, add a NavigationLink to each one that'll bring the user to the PostDetailView, which will show more details about the Post.
                            ForEach(searchPosts) { post in
                                NavigationLink {
                                    PostDetailView(post: post, selectedTab: $selectedTab)
                                        .environment(authManager)
                                } label: {
                                    FeedPostRow(post: post)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    // Make it so we can refresh the feed for new posts by pulling:
                    .refreshable {
                        await betweenPost.refresh()
                    }
                }
            }
            .navigationTitle("My Feed")
            .searchable(text: $searchText, prompt: "Search Textbooks...")
            // By using a .task{}, this activates as soon as the view appears so the poasts are loaded efficiently.
            .task {
                await betweenPost.loadPosts()
            }
            
            // Create a .alert{} to catch errors and display what went wrong to the user. The user can dismiss the alert.
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { betweenPost.errorMessage != nil },
                    set: { _ in betweenPost.errorMessage = nil }
                ),
                actions: {
                    Button("OK", role: .cancel) {}
                },
                message: {
                    Text(betweenPost.errorMessage ?? "")
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        authManager.signOut()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}

// Create a sub-view dedicated to row item UI. Every post will be sent through this to become a proper row item.
private struct FeedPostRow: View {
    // Create an instance of Post so that when a post is sent into this view via FeedPostRow(post: post), this post instance will contain that data.
    let post: Post
    
    // The main UI for the row items:
    var body: some View {
        // VStack so the Text is displayed vertically on top of each other. We'll be showing the Title, author, and price in the row items. Users can tap the row item to see more detail on the post. Price is the most interesting because we can .currency() to format it so that the currency that appears depends on the User's settings.
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)
            Text(post.author)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(post.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.title3.weight(.semibold))
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}
